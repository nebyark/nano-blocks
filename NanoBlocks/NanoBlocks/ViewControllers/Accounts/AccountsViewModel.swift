//
//  AccountsViewModel.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 1/13/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import Foundation

struct AccountsViewModel {

    fileprivate var totalNano: NSDecimalNumber {
        let total = WalletManager.shared.accounts.reduce(NSDecimalNumber(decimal: 0.0), { (result, account) in
            result.adding(account.balance.decimalNumber)
        })
        return total
    }

    var currencyValue: String {
        if Currency.isSecondarySelected == true {
            return Currency.secondary.typePostfix
        } else {
            return CURRENCY_NAME
        }
    }

    var balanceValue: String {
        if !Currency.isSecondarySelected {
            return self.getTotalNano()
        } else {
            return Currency.secondary.convert(self.totalNano)
        }
    }

    mutating func toggleCurrency() {
        Currency.setSecondary(!Currency.isSecondarySelected)
    }
    
    func getTotalNano() -> String {
        return self.totalNano.mxrbString.formattedAmount
    }
}
