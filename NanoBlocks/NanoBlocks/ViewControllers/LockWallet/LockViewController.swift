//
//  LockViewController.swift
// NanoBlocks
//
//  Created by Ben Kray on 3/10/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import UIKit

class LockViewController: TransparentNavViewController {

    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var messageLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            // safe area by default
        } else {
            // XIB file hack for backwards compatibilty
            titleLabel?.topAnchor.constraint(equalTo: view.topAnchor, constant: 60).isActive = true
        }
        guard let epoch = Keychain.standard.get(key: KeychainKey.lockUntilDate)?.uint32 else { return }
        let date = Date(timeIntervalSince1970: TimeInterval(epoch))
        let localizedDate = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .long)
        messageLabel?.text = "You've been locked out until \(localizedDate)"
    }
}
