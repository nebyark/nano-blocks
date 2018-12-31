//
//  PersistentStore.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 1/5/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import Foundation
import RealmSwift

struct PersistentStore {
    
    static func handleMigration() {
        let config = Realm.Configuration(
            schemaVersion: 3,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 3 {
                    migration.enumerateObjects(ofType: AccountInfo.className(), { (old, new) in
                        guard
                            let old = old,
                            let new = new,
                            let oldBalance = old["balance"] as? Double
                        else { return }
                        // new balance is stored as string
                        let oldBalanceNumber = NSDecimalNumber(decimal: Decimal(oldBalance))
                        new["balance"] = oldBalanceNumber.mxrbAmount.rawString
                    })
                }
        })
        Realm.Configuration.defaultConfiguration = config
    }
    
    // MARK: - Accounts
    
    static func remove(account: AccountInfo) {
        try? Realm().delete(account)
    }
    
    static func getAccounts() -> [AccountInfo] {
        do {
            return try Array(Realm().objects(AccountInfo.self))
        } catch {
            Lincoln.log("Error getting accounts: \(error.localizedDescription)")
            return []
        }
    }
    
    static func addAccount(name: String, address: String, index: Int) {
        let account = AccountInfo()
        account.name = name
        account.address = address
        account.index = index
        add(account)
        Lincoln.log("Account '\(name)' saved", inConsole: true)
    }
    
    // MARK: - Address Book
    
    static func getAddressEntries() -> [AddressEntry] {
        do {
            return try Array(Realm().objects(AddressEntry.self))
        } catch {
            return []
        }
    }
    
    static func addAddressEntry(_ name: String, address: String) {
        let entry = AddressEntry()
        entry.address = address
        entry.name = name
        add(entry)
        Lincoln.log("Address entry '\(name)' saved", inConsole: true)
    }
    
    static func removeAddressEntry(_ entry: AddressEntry) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.delete(entry)
            }
        } catch {
            
        }
    }
    
    static func updateAddressEntry(address: String, name: String, originalAddress: String) {
        do {
            let realm = try Realm()
            try realm.write {
                guard let result = realm.objects(AddressEntry.self).filter("address == %@", originalAddress).first else { return }
                result.name = name
                result.address = address
            }
        } catch {
            
        }
    }
    
    // MARK: - Blocks
    
    static func removeBlockHistory(for account: String?) {
        guard let account = account else { return }
        do {
            let realm = try Realm()
            let results = realm.objects(SimpleBlock.self).filter("owner == %@", account)
            try realm.write {
                realm.delete(results)
            }
        } catch {
            
        }
    }
    
    static func updateBlockHistory(for account: AccountInfo, history: [SimpleBlockBridge]) {
        let blockSet = Set(account.blockHistory.map { $0.blockHash })
        let blocks: [SimpleBlock] = history
            .filter { !blockSet.contains($0.blockHash) }
            .map {
                let b = SimpleBlock()
                b.account = $0.account
                b.amount = $0.amount
                b.blockHash = $0.blockHash
                b.owner = account.address ?? ""
                b.type = $0.type
                return b
            }
        guard blocks.count > 0 else { return }
        write {
            account.blockHistory.insert(contentsOf: blocks, at: 0)
            Lincoln.log("BLOCK HISTORY COUNT - \(account.blockHistory.count)")
        }
        
    }
    
    static func addBlock(_ block: SimpleBlockBridge, owner: String?) {
        guard let owner = owner else { return }
        // verify block hasn't already been saved
        let results = getBlockHistory(for: owner)
        guard !results.contains(where: { block.blockHash == $0.blockHash }) else { return }
        let b = SimpleBlock()
        b.account = block.account
        b.amount = block.amount
        b.blockHash = block.blockHash
        b.owner = owner
        b.type = block.type
        add(b)
    }
    
    static func getBlockHistory(for account: String?) -> [SimpleBlock] {
        guard let account = account else { return [] }
        do {
            let realm = try Realm()
            let results = realm.objects(SimpleBlock.self).filter("owner == %@", account)//.sorted(byKeyPath: "date", ascending: false)
            return Array(results)
        } catch {
            return []
        }
    }
    
    // MARK: - Helpers
    
    static func clearAll() {
        do {
            let realm = try Realm()
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            
        }
    }
    
    static func write(_ closure: () -> Void) {
        do {
            let realm = try Realm()
            try realm.write {
                closure()
            }
        } catch {
            
        }
    }
    
    static func add(_ record: Object) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(record)
            }
        } catch { }
    }
}
