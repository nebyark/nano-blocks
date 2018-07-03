//
//  EnterAddressEntryViewController.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 2/6/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import UIKit

class EnterAddressEntryViewController: TransparentNavViewController {
    
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var addressLabel: UILabel?
    @IBOutlet weak var nameTop: NSLayoutConstraint!
    @IBOutlet weak var nameHeight: NSLayoutConstraint!
    @IBOutlet weak var nameView: UIView?
    @IBOutlet weak var addressTextField: UITextField?
    @IBOutlet weak var nameTextField: UITextField?
    @IBOutlet weak var titleLabel: UILabel?
    var onAddressSaved: ((String?) -> Void)?
    fileprivate let viewModel: EnterAddressEntryViewModel
    
    init(with viewModel: EnterAddressEntryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if viewModel.addressOnly {
            nameHeight.constant = 0
            nameTop.constant = 0
            nameView?.isHidden = true
        }
        titleLabel?.text = viewModel.title
        addressTextField?.text = viewModel.address
        nameTextField?.text = viewModel.name
        nameLabel?.text = String.localize("name").uppercased()
        addressLabel?.text = String.localize("address").uppercased()
    }
    
    // MARK: - Setup
    
    override func setupNavBar() {
        super.setupNavBar()
        if viewModel.addressOnly {
            let closeButton = UIBarButtonItem(image: #imageLiteral(resourceName: "close2"), style: .done, target: self, action: #selector(dismissTapped))
            closeButton.tintColor = .black
            navigationItem.leftBarButtonItem = closeButton
        }
        let rightBarItem = UIBarButtonItem(title: .localize("save"), style: .done, target: self, action: #selector(saveTapped))
        rightBarItem.tintColor = .black
        navigationItem.rightBarButtonItem = rightBarItem
    }
    
    // MARK: - Actions
    
    @IBAction func scanTapped(_ sender: Any) {
        let scanVC = QRScanViewController()
        scanVC.onQRCodeScanned = { [weak self] (result) in
            self?.addressTextField?.text = result.address
        }
        present(UINavigationController(rootViewController: scanVC), animated: true)
    }
    
    @IBAction func pasteTapped(_ sender: Any) {
        guard let paste = UIPasteboard.general.string, !paste.isEmpty else {
            Banner.show(.localize("no-pastable-item"), style: .warning)
            return
        }
        addressTextField?.text = paste
    }
    
    @objc fileprivate func dismissTapped() {
        dismiss(animated: true)
    }
    
    @objc fileprivate func saveTapped() {
        guard let address = addressTextField?.text, let _ = WalletUtil.derivePublic(from: address) else {
            Banner.show(.localize("invalid-nano-address"), style: .warning)
            return
        }
        if viewModel.addressOnly {
            dismiss(animated: true)
            onAddressSaved?(address)
            return
        }
        guard let name = nameTextField?.text, !name.isEmpty else {
            Banner.show(.localize("no-name-provided"), style: .warning)
            return
        }
        guard !PersistentStore.getAddressEntries().contains(where: { $0.address == address }) || viewModel.isEditing else {
            Banner.show(.localize("address-already-exists"), style: .warning)
            return
        }
        if viewModel.isEditing {
            PersistentStore.updateAddressEntry(address: address, name: name, originalAddress: viewModel.address ?? "")
        } else {
            PersistentStore.addAddressEntry(name, address: address)
        }
        onAddressSaved?(address)
    }
}
