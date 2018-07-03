//
//  SendViewController.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 1/20/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import UIKit

protocol SendViewControllerDelegate: class {
    func scanTapped()
    func sendTapped(txInfo: TxInfo)
    func addressBookTapped()
    func enterAddressTapped()
    func enterAmountTapped()
    func closeTapped()
}

class SendViewController: UIViewController {

    @IBOutlet weak var sendButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var recipientLabel: UILabel?
    @IBOutlet weak var sendLabel: UILabel?
    @IBOutlet weak var addAddressButton: UIButton?
    @IBOutlet weak var nameButton: UIButton?
    @IBOutlet weak var nameAddressStackView: UIStackView?
    @IBOutlet weak var enterAddressButton: LeftAlignedIconButton?
    @IBOutlet weak var enterAmountButton: LeftAlignedIconButton?
    @IBOutlet weak var currencyLabel: UILabel?
    @IBOutlet weak var amountLabel: UILabel?
    @IBOutlet weak var backdropView: UIView?
    @IBOutlet weak var contentView: UIView?
    @IBOutlet weak var addressLabel: UILabel?
    @IBOutlet weak var sendButton: UIButton?
    @IBOutlet weak var scanButton: UIButton?
    @IBOutlet weak var bgView: UIView?
    weak var delegate: SendViewControllerDelegate?
    private(set) var account: AccountInfo
    
    init(account: AccountInfo) {
        self.account = account
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.3) {
            self.backdropView?.alpha = 1.0
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIView.animate(withDuration: 0.3) {
            self.backdropView?.alpha = 0.0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        backdropView?.alpha = 0.0
        backdropView?.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        sendLabel?.text = String.localize("send").uppercased()
        recipientLabel?.text = String.localize("recipient").uppercased()
        // iphone x
        if UIDevice.isIPhoneX {
            sendButtonBottomConstraint.constant = 50
        } else {
            sendButtonBottomConstraint.constant = 25
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgView?.roundCorners([.topRight, .topLeft], radius: 20.0)
        // Button stuffs
        [sendButton, scanButton].forEach { $0?.layer.cornerRadius = 23.0; $0?.clipsToBounds = true }
        scanButton?.layer.borderWidth = 1.0
        scanButton?.layer.borderColor = AppStyle.lightGrey.cgColor
        scanButton?.setTitle(.localize("scan-qr"), for: .normal)
        sendButton?.setTitle(.localize("send"), for: .normal)
        let gradient = AppStyle.buttonGradient
        gradient.frame = sendButton?.bounds ?? .zero
        gradient.cornerRadius = 23.0
        sendButton?.layer.insertSublayer(gradient, at: 0)
        
        nameButton?.addTarget(self, action: #selector(enterAddressTapped(_:)), for: .touchUpInside)
        nameButton?.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        [enterAmountButton, enterAddressButton].forEach {
            $0?.setTitleColor(AppStyle.Color.lowAlphaBlack, for: .normal)
        }
        enterAmountButton?.setTitle(.localize("enter-amount"), for: .normal)
        enterAddressButton?.setTitle(.localize("enter-address"), for: .normal)
    }
    
    // MARK: - Setup
    
    fileprivate func setupView() {
        // Gesture stuff
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeDown(_:)))
        swipeGesture.direction = .down
        view.addGestureRecognizer(swipeGesture)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        contentView?.addGestureRecognizer(tapGesture)
        
        let dismissGesture = UITapGestureRecognizer(target: self, action: #selector(closeTapped(_:)))
        view.addGestureRecognizer(dismissGesture)
        
        let amountGesture = UITapGestureRecognizer(target: self, action: #selector(enterAmountTapped(_:)))
        amountLabel?.addGestureRecognizer(amountGesture)
        amountLabel?.isUserInteractionEnabled = true
    }
    
    // MARK: - Actions
    
    @IBAction func addAddressTapped(_ sender: Any) {
        showTextDialogue(.localize("enter-name"), placeholder: .localize("name"), keyboard: .default) { [weak self] (textField) in
            guard let name = textField.text, !name.isEmpty, let address = self?.addressLabel?.text else { return }
            PersistentStore.addAddressEntry(name, address: address)
            Banner.show(.localize("arg-entry-saved", arg: name), style: .success)
            self?.addAddressButton?.isHidden = true
            self?.nameButton?.setTitle(name, for: .normal)
        }
    }
    
    @IBAction func addressBookTapped(_ sender: Any) {
        delegate?.addressBookTapped()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func sendTapped(_ sender: Any) {
        // Validate balance, address, etc
        guard let amount = amountLabel?.text, let amountValue = BDouble(amount), amountValue > 0.0 else {
            Banner.show(.localize("please-enter-amount"), style: .warning)
            return
        }
        guard let recipientAddress = addressLabel?.text, WalletUtil.derivePublic(from: recipientAddress) != nil, let recipientName = nameButton?.titleLabel?.text else {
            Banner.show(.localize("enter-recipient-address"), style: .warning)
            return
        }
        let remaining = account.mxrbBalance.bNumber - amountValue
        guard remaining >= 0.0 else {
            Banner.show(.localize("insufficient-funds"), style: .danger)
            return
        }
        let txInfo = TxInfo(recipientName: recipientName, recipientAddress: recipientAddress, amount: amount, balance: remaining.decimalExpansion(precisionAfterComma: 6), accountInfo: account)
        delegate?.sendTapped(txInfo: txInfo)
    }
    
    @IBAction func enterAmountTapped(_ sender: Any) {
        delegate?.enterAmountTapped()
    }
    
    @IBAction func enterAddressTapped(_ sender: Any) {
        delegate?.enterAddressTapped()
    }
    
    @IBAction func scanTapped(_ sender: Any) {
        delegate?.scanTapped()
    }
    
    @objc func swipeDown(_ gesture: UISwipeGestureRecognizer) {
        dismiss(animated: true)
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        delegate?.closeTapped()
        dismiss(animated: true)
    }
    
    func apply(amount: String) {
        amountLabel?.text = amount.trimTrailingZeros()
        amountLabel?.isHidden = false
        currencyLabel?.isHidden = false
        enterAmountButton?.isHidden = true
    }
    
    func apply(entry: AddressEntry) {
        addressLabel?.text = entry.address
        nameButton?.setTitle(entry.name, for: .normal)
        nameAddressStackView?.isHidden = false
        enterAddressButton?.isHidden = true
        addAddressButton?.isHidden = true
        addAddressButton?.isHidden = !PersistentStore
            .getAddressEntries()
            .filter({ $0.address == entry.address })
            .isEmpty
    }
    
    func apply(scanResult: PaymentInfo) {
        addressLabel?.text = scanResult.address
        nameAddressStackView?.isHidden = false
        enterAddressButton?.isHidden = true
        if let existingContact = PersistentStore.getAddressEntries().filter({ $0.address == scanResult.address }).first {
            addAddressButton?.isHidden = true
            nameButton?.setTitle(existingContact.name, for: .normal)
        } else {
            nameButton?.setTitle(.localize("unknown"), for: .normal)
            addAddressButton?.isHidden = false
        }
        
        if let amount = scanResult.nanoAmount {
            amountLabel?.text = amount
            enterAmountButton?.isHidden = true
            amountLabel?.isHidden = false
            currencyLabel?.isHidden = false
        }
    }
}
