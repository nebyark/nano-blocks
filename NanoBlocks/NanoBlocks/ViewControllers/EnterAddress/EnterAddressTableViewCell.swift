//
//  EnterAddressTableViewCell.swift
// NanoBlocks
//
//  Created by Ben Kray on 3/26/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import UIKit

class EnterAddressTableViewCell: UITableViewCell {

    @IBOutlet weak var addressLabel: UILabel?
    @IBOutlet weak var nameLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .clear
        addressLabel?.textColor = AppStyle.Color.lowAlphaWhite
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        self.alpha = highlighted ? 0.3 : 1.0
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        self.alpha = selected ? 0.3 : 1.0
    }
    
}
