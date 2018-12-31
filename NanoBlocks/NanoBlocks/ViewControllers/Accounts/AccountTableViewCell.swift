//
//  AccountTableViewCell.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 1/3/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import UIKit

class AccountTableViewCell: UITableViewCell {

    @IBOutlet weak var unitLabel: UILabel?
    @IBOutlet weak var forwardImageView: UIImageView?
    @IBOutlet weak var balanceLabel: UILabel?
    @IBOutlet weak var addressLabel: UILabel?
    @IBOutlet weak var accountNameLabel: UILabel?
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        self.alpha = highlighted ? 0.3 : 1.0
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        self.alpha = selected ? 0.3 : 1.0
    }
    
    func prepare(with account: AccountInfo?, useSecondaryCurrency: Bool) {
        backgroundColor = UIColor.white.withAlphaComponent(0.04)
        layer.cornerRadius = 10.0
        let img = #imageLiteral(resourceName: "forward2").withRenderingMode(.alwaysTemplate)
        forwardImageView?.tintColor = .white
        forwardImageView?.image = img
        
        addressLabel?.text = account?.address
        accountNameLabel?.text = account?.name
        let accountValue = account?.balance ?? "0"
        let valueString: String
        if useSecondaryCurrency {
            let secondary = Currency.secondary
            valueString = secondary.convert(accountValue.decimalNumber)
            unitLabel?.text = secondary.rawValue.uppercased()
        } else {
            valueString = account?.formattedBalance ?? "0"
            unitLabel?.text = "NANO"
        }
        balanceLabel?.text = valueString
    }
    
}
