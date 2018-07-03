//
//  PassphraseCollectionViewCell.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 1/8/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import UIKit

class PassphraseCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var wordTextField: UITextField?
    static let identifier: String = "PassphraseCollectionViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
