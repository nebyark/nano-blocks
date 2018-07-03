//
//  ReceiveViewController.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 12/23/17.
//  Copyright © 2017 Planar Form. All rights reserved.
//

import UIKit

//protocol ReceiveViewControllerDelegate: class {
//    func requestAmountTapped()
//    func closeTapped()
//}

class ReceiveViewController: UIViewController {
    
    @IBOutlet weak var requestBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var receiveLabel: UILabel?
    @IBOutlet weak var addressLabelWidth: NSLayoutConstraint!
    @IBOutlet weak var accountNameLabel: UILabel?
    @IBOutlet weak var contentView: UIView?
    @IBOutlet weak var requestButton: UIButton?
    @IBOutlet weak var shareButton: UIButton?
    @IBOutlet weak var backdropView: UIView?
    @IBOutlet weak var bgView: UIView?
    @IBOutlet weak var qrCodeImageView: UIImageView?
    @IBOutlet weak var addressLabel: UILabel?
    var onRequestAmountTapped: (() -> Void)?
    var onDismiss: (() -> Void)?
    
    let account: AccountInfo
    fileprivate let minAddressWidth: CGFloat = 150.0
    
    init(with accountInfo: AccountInfo) {
        self.account = accountInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        receiveLabel?.text = String.localize("receive").uppercased()
        if UIDevice.isIPhoneX {
            requestBottomConstraint.constant = 50
        } else {
            requestBottomConstraint.constant = 25
        }
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgView?.roundCorners([.topRight, .topLeft], radius: 20.0)
        [requestButton, shareButton].forEach { $0?.layer.cornerRadius = 23.0; $0?.clipsToBounds = true }
        shareButton?.layer.borderWidth = 1.0
        shareButton?.layer.borderColor = AppStyle.lightGrey.cgColor
        requestButton?.setTitle(.localize("request-amount"), for: .normal)
        shareButton?.setTitle(.localize("share"), for: .normal)
        let gradient = AppStyle.buttonGradient
        gradient.frame = requestButton?.bounds ?? .zero
        gradient.cornerRadius = 23.0
        requestButton?.layer.insertSublayer(gradient, at: 0)
    }
    
    // MARK: - Setup
    
    fileprivate func setupView() {
        guard let qrImageView = qrCodeImageView, let address = account.address else { return }
        qrImageView.image = UIImage
            .qrCode(data: ("xrb:" + address).data(using: .utf8), color: .black)?
            .resize(CGSize(width: qrImageView.bounds.width, height: qrImageView.bounds.height))
        let qrGesture = UITapGestureRecognizer(target: self, action: #selector(copyTapped(_:)))
        qrImageView.addGestureRecognizer(qrGesture)
        qrImageView.isUserInteractionEnabled = true
        backdropView?.alpha = 0.0
        backdropView?.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        let dismissGesture = UITapGestureRecognizer(target: self, action: #selector(closeTapped(_:)))
        view.addGestureRecognizer(dismissGesture)
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeDown(_:)))
        swipeGesture.direction = .down
        view.addGestureRecognizer(swipeGesture)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        contentView?.addGestureRecognizer(tapGesture)
        
        accountNameLabel?.text = account.name
        addressLabel?.text = address
        addressLabel?.isUserInteractionEnabled = true
        addressLabel?.minimumScaleFactor = 0.5
        let addressTapGesture = UITapGestureRecognizer(target: self, action: #selector(addressTapped))
        addressLabel?.addGestureRecognizer(addressTapGesture)
    }
    
    // MARK: - Actions
    
    @objc fileprivate func addressTapped() {
        addressLabelWidth.constant = addressLabelWidth.constant == minAddressWidth ? view.bounds.width - 16 : minAddressWidth
        addressLabel?.adjustsFontSizeToFitWidth = addressLabelWidth.constant != minAddressWidth
    }
    
    @IBAction func copyTapped(_ sender: Any) {
        UIPasteboard.general.string = account.address
        Banner.show(.localize("address-copied-clipboard"), style: .success)
    }
    
    @IBAction func shareTapped(_ sender: Any) {
        guard let address = account.address else { return }
        var items: [Any] = []
        let addressText: String = .localize("send-to-arg", arg:  address)
        if let image = qrCodeImageView?.image {
            items.append(image)
        }
        items.append(addressText)
        let shareVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(shareVC, animated: true)
    }
    
    @IBAction func requestTapped(_ sender: Any) {
        onRequestAmountTapped?()
    }
    
    @objc func swipeDown(_ gesture: UISwipeGestureRecognizer) {
        dismiss(animated: true)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        onDismiss?()
        dismiss(animated: true)
    }
}
