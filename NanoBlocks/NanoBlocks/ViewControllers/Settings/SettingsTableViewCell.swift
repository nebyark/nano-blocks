//
//  SettingsTableViewCell.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 2/6/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var rightImageView: UIImageView?
    @IBOutlet weak var valueLabel: UILabel?
    @IBOutlet weak var settingsTitleLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        valueLabel?.text = ""
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
