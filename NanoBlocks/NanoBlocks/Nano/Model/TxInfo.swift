//
//  TxInfo.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 1/31/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import Foundation

struct TxInfo {
    var recipientName: String
    var recipientAddress: String
    var amount: String
    var rawBalance: String
    var accountInfo: AccountInfo

    func createBlock(with keyPair: KeyPair) -> StateBlock? {
        guard
            self.amount.decimalNumber.decimalValue > 0.0
        else {
            return nil
        }
        // Generate block
        var block = StateBlock(.send)
        block.previous = self.accountInfo.frontier.uppercased()
        block.link = self.recipientAddress
        block.rawDecimalBalance = self.rawBalance.decimalNumber
        block.representative = self.accountInfo.representative

        if block.build(with: keyPair) {
            return block
        } else {
            return nil
        }
    }
}
