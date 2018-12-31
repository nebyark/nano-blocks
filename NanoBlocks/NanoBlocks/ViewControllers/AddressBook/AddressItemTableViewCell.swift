//
//  AddressItemTableViewCell.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 1/23/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import UIKit

class AddressItemTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView?
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var addressLabel: UILabel?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.iconImageView?.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
