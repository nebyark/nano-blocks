//
//  NumpadCollectionViewCell.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 1/28/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import UIKit

class NumpadCollectionViewCell: UICollectionViewCell {

    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor.black.withAlphaComponent(0.05) : UIColor.white.withAlphaComponent(0.04)
        }
    }
    
    @IBOutlet weak var valueImageView: UIImageView?
    @IBOutlet weak var valueLabel: UILabel?
    static let identifier: String = "NumpadCollectionViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        valueLabel?.textColor = AppStyle.Color.lowAlphaBlack
    }

}
