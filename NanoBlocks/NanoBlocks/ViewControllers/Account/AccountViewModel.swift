//
//  AccountViewModel.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 1/12/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import Foundation

class AccountViewModel {
    
    enum RefineType {
        case latestFirst
        case oldestFirst
        case largestFirst
        case smallestFirst
        case sent
        case received
        
        var title: String {
            switch self {
            case .latestFirst: return String.localize("latest-sort").uppercased()
            case .oldestFirst: return String.localize("oldest-sort").uppercased()
            case .smallestFirst: return String.localize("smallest-sort").uppercased()
            case .largestFirst: return String.localize("largest-sort").uppercased()
            case .received: return String.localize("received-filter").uppercased()
            case .sent: return String.localize("sent-filter").uppercased()
            }
        }
    }
    
    private(set) var isFetching: Bool = false
    private(set) var account: AccountInfo
    private(set) var history: [SimpleBlockBridge] = []
    private(set) var refined: [SimpleBlockBridge] = []
    private(set) var blockCheck: Set<String> = []
    private(set) var balance: AccountBalance?
    private(set) var isShowingSecondary: Bool = false
    var balanceValue: String {
        if !isShowingSecondary {
            return account.mxrbBalance.trimTrailingZeros()
        } else {
            let secondary = Currency.secondary
            currencyValue = secondary.rawValue.uppercased() + (secondary == .lambo ? "" : " (\(secondary.symbol))")
            return secondary.convertToFiat(account.balance.bNumber)
        }
    }
    private(set) var currencyValue: String = ""
    private(set) var refineType: RefineType = .latestFirst
    var onNewBlockBroadcasted: (() -> Void)?
    var updateView: (() -> Void)?
    
    var count: Int {
        return refined.count
    }
    
    init(with account: AccountInfo) {
        self.account = account
        self.history = account.blockHistory.compactMap { $0 as SimpleBlockBridge }
        self.refined = self.history
    }
    
    subscript(index: Int) -> SimpleBlockBridge? {
        guard index < refined.count else { return nil }
        return refined[index]
    }
    
    func toggleCurrency() {
        if isShowingSecondary {
            currencyValue = "NANO"
        } else {
            let secondary = Currency.secondary
            currencyValue = secondary.rawValue.uppercased() + (secondary == .lambo ? "" : " (\(secondary.symbol))")            
        }
        isShowingSecondary = !isShowingSecondary
    }
    
    func initHistory() {
        history = PersistentStore.getBlockHistory(for: account.address)
        blockCheck = Set(history.map { $0.blockHash })
    }
    
    /// Completion returns count of pending blocks
    func getPending(shouldOpen: Bool = false, completion: ((Int) -> Void)? = nil) {
        guard let keyPair = WalletManager.shared.keyPair(at: account.index),
            let acc = keyPair.xrbAccount else { return }
        // fetch pending
        isFetching = true
        NetworkAdapter.getPending(for: acc) { [weak self] (pending) in
            guard let me = self else { return }
            me.isFetching = false
            completion?(pending.count)
            me.handlePending(pending, previous: me.account.frontier, shouldOpen: shouldOpen)
        }
    }
    
    /// Recursively handle pending
    func handlePending(_ pending: [String], previous: String, shouldOpen: Bool) {
        guard !pending.isEmpty,
            let keyPair = WalletManager.shared.keyPair(at: account.index),
            let account = keyPair.xrbAccount else { return }
        var remaining = pending
        // Pending block order in array is newest -> oldest
        let source = remaining.removeLast()
        isFetching = true
        NetworkAdapter.blockInfo(hashes: [source]) { [weak self] (info, error) in
            self?.isFetching = false
            guard let me = self,
                let amount = info.first?.amount,
                let balance = BInt(me.account.balance),
                let amt = BInt(amount) else { return }
            var block = shouldOpen ? StateBlock(.open) : StateBlock(.receive)
            let randomRep = WalletManager.shared.getRandomRep()?.account ?? account
            block.previous = previous
            block.link = source
            block.balanceValue = balance + amt
            if me.account.representative.isEmpty {
                block.representative = randomRep
            } else {
                block.representative = me.account.representative
            }
            guard me.account.balance.bNumber + amount.bNumber >= me.account.balance.bNumber else {
                Banner.show("Account balance should be greater than previous balance", style: .danger)
                return
            }
            guard block.build(with: keyPair) else { return }
            if shouldOpen {
                Banner.show(.localize("opening-account"), style: .success)
            }
            me.isFetching = true
            BlockHandler.handle(block, for: account) { (result) in
                me.isFetching = false
                switch result {
                case .success(let newHash):
                    // Balance must be updated otherwise consecutive recieves can be seen as sends due to a negative balance
                    PersistentStore.write {
                        me.account.balance = block.balance
                    }
                    me.handlePending(remaining, previous: newHash, shouldOpen: false)
                    me.onNewBlockBroadcasted?()
                case .failure(let error):
                    Banner.show(.localize("receive-error-arg", arg: error.description), style: .danger)
                }
            }
        }
    }
    
    func getAccountInfo(completion: (() -> Void)? = nil) {
        guard let acc: String = WalletManager.shared.keyPair(at: account.index)?.xrbAccount else { return }
        NetworkAdapter.getLedger(account: acc) { [weak self] (info) in
            if let info = info {
                PersistentStore.write {
                    self?.account.copyProperties(from: info)
                }
            } else {
                // Assume account is not open yet
                self?.getPending(shouldOpen: true)
            }
            completion?()
        }
    }
    
    func getHistory(completion: @escaping () -> Void) {
        guard let acc: String = WalletManager.shared.keyPair(at: account.index)?.xrbAccount else { return }
        NetworkAdapter.getAccountHistory(account: acc, count: account.blockCount) { (chain) in
            self.history = chain
            self.refined = chain
            PersistentStore.updateBlockHistory(for: self.account, history: chain)
            completion()
        }
    }
    
    func repair(_ completion: @escaping () -> Void) {
        PersistentStore.removeBlockHistory(for: account.address)
        refined = []
        history = []
        blockCheck.removeAll()
        getHistory {
            completion()
        }
    }
    
    func refine(_ type: RefineType) {
        switch type {
        case .latestFirst:
            refined = history
        case .oldestFirst:
            refined = history.reversed()
        case .received:
            refined = history.filter { $0.type == Block.BlockType.receive.rawValue }
        case .sent:
            refined = history.filter { $0.type == Block.BlockType.send.rawValue }
        case .largestFirst:
            refined = history.sorted(by: { (blockA, blockB) -> Bool in
                return Double(blockA.amount) ?? 0.0 > Double(blockB.amount) ?? 0.0
            })
        case .smallestFirst:
            refined = history.sorted(by: { (blockA, blockB) -> Bool in
                return Double(blockA.amount) ?? 0.0 < Double(blockB.amount) ?? 0.0
            })
        }
        refineType = type
        updateView?()
    }
}
