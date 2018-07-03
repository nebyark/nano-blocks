//
//  ImportWalletViewController.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 1/7/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import UIKit

protocol ImportWalletViewControllerDelegate: class {
    func seedTapped()
    func passphraseTapped()
}

class ImportWalletViewController: TransparentNavViewController {
    
    @IBOutlet weak var passphraseButton: LeftAlignedIconButton?
    @IBOutlet weak var seedButton: LeftAlignedIconButton?
    @IBOutlet weak var subtitleLabel: UILabel?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var importWalletImageView: UIImageView?
    weak var delegate: ImportWalletViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            // safe area by default
        } else {
            // XIB file hack for backwards compatibilty
            titleLabel?.topAnchor.constraint(equalTo: view.topAnchor, constant: 60).isActive = true
        }
        importWalletImageView?.image = #imageLiteral(resourceName: "import_wallet").withRenderingMode(.alwaysTemplate)
        importWalletImageView?.tintColor = .white
        titleLabel?.text = .localize("import-wallet-cap")
        subtitleLabel?.text = .localize("import-wallet-subtitle")
        passphraseButton?.setTitle(.localize("passphrase"), for: .normal)
        seedButton?.setTitle(.localize("seed"), for: .normal)
        seedButton?.setImage(#imageLiteral(resourceName: "key").withRenderingMode(.alwaysTemplate), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "back2"), style: .plain, target: self, action: #selector(backTapped))
        backButton.tintColor = .white
        navigationItem.leftBarButtonItem = backButton
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    // MARK: - Actions
    
    @objc fileprivate func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func seedTapped(_ sender: Any) {
        delegate?.seedTapped()
    }
    
    @IBAction func passphraseTapped(_ sender: Any) {
        delegate?.passphraseTapped()
    }
}
