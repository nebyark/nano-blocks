//
//  AccountsViewModel.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 1/13/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import Foundation

struct AccountsViewModel {
    
    private(set) var balanceValue: String = ""
    private(set) var currencyValue: String
    private(set) var isShowingSecondary: Bool = false
    
    init() {
        currencyValue = "NANO"
        balanceValue = getTotalNano()
    }
    
    mutating func toggleCurrency() {
        if isShowingSecondary {
            currencyValue = "NANO"
            balanceValue = getTotalNano()
        } else {
            let secondary = Currency.secondary
            currencyValue = secondary.rawValue.uppercased() + (secondary == .lambo ? "" : " (\(secondary.symbol))")
            let total = WalletManager.shared.accounts.reduce(BDouble(0.0), { (result, account) in
                result + account.balance.bNumber
            })
            balanceValue = secondary.convertToFiat(total)
        }
        isShowingSecondary = !isShowingSecondary
    }
    
    func getTotalNano() -> String {
        let total = WalletManager.shared.accounts.reduce(BDouble(0.0), { (result, account) in
            result + account.balance.bNumber
        })
        return total.toMxrb.trimTrailingZeros()
    }
}
