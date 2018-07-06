//
//  TransactionTableViewCell.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 1/11/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var sourceDestLabel: UILabel?
    @IBOutlet weak var typeIndicatorLabel: UILabel?
    @IBOutlet weak var typeLabel: UILabel?
    @IBOutlet weak var amountLabel: UILabel?
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        self.alpha = highlighted ? 0.3 : 1.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        self.alpha = selected ? 0.3 : 1.0
    }
    
    func prepare(with tx: SimpleBlockBridge?, useSecondaryCurrency: Bool) {
        backgroundColor = UIColor.white.withAlphaComponent(0.04)
        contentView.backgroundColor = .clear
        layer.cornerRadius = 10.0
        guard let tx = tx, let type = Block.BlockType(rawValue: tx.type) else { return }
        typeLabel?.text = type == .send ? .localize("sent-filter") : .localize("received-filter")
        let secondary = Currency.secondary
        var stringValue = ""
        let value = tx.amount.bNumber.toMxrbValue
        if useSecondaryCurrency {
            let converted = secondary.convertToFiat(tx.amount.bNumber)
            stringValue = "\(converted) " + secondary.rawValue.uppercased()
        } else {
            stringValue = "\(value.decimalExpansion(precisionAfterComma: 6).trimTrailingZeros()) NANO"
        }
        amountLabel?.text = stringValue
        let alias = PersistentStore.getAddressEntries().first(where: { $0.address == tx.account })?.name
        sourceDestLabel?.text = alias ?? tx.account
        typeIndicatorLabel?.text = type == .receive ? "+" : "-"
    }
    
}
