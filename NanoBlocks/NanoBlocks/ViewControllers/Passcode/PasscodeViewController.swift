//
//  PasscodeViewController.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 2/13/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import UIKit
import Sodium

class PasscodeViewController: TransparentNavViewController {

    enum State {
        // User is entering current passcode
        case entering
        // User is creating a new passcode
        case creating
        // User is confirming temp passcode
        case confirming
    }
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var subtitleLabel: UILabel?
    @IBOutlet weak var digit0: UIView?
    @IBOutlet weak var digit1: UIView?
    @IBOutlet weak var digit2: UIView?
    @IBOutlet weak var digit3: UIView?
    @IBOutlet weak var digit4: UIView?
    @IBOutlet weak var digit5: UIView?
    @IBOutlet weak var collectionView: UICollectionView?
    fileprivate let rows: CGFloat = 4
    fileprivate let cols: CGFloat = 3
    fileprivate var passcode: String = ""
    fileprivate let style: Style
    fileprivate let hideNav: Bool
    fileprivate var state: State = .creating {
        didSet {
            // On state change, reload view
            passcode = ""
            setupView()
        }
    }
    fileprivate var tempPasscode: String = ""
    var onAuthenticated: (() -> Void)?
    var onDismiss: (() -> Void)?
    var onLock: (() -> Void)?
    let action: PasscodeAction
    private var isAuthenticated: Bool = false
    
    init(action: PasscodeAction, style: Style, hideNav: Bool) {
        self.action = action
        self.hideNav = hideNav
        self.state = action == .create ? .creating : .entering
        self.style = style
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            // safe area by default
        } else {
            // XIB file hack for backwards compatibilty
            topConstraint.constant = 60
        }
        
        if hideNav {
            view.alpha = 0.0
            UIView.animate(withDuration: 0.5) {
                self.view.alpha = 1.0
            }
        }
        if style == .blue {
            view.backgroundColor = .clear
            [subtitleLabel, titleLabel].forEach { $0?.textColor = .white }
        } else {
            [subtitleLabel, titleLabel].forEach { $0?.textColor = .black }
        }
        setupView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupKeyboard()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if self.isMovingFromParentViewController && !isAuthenticated {
            // User is going back
            onDismiss?()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard !hideNav else { return }
        if style == .blue {
            let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "back2"), style: .plain, target: self, action: #selector(backTapped))
            backButton.tintColor = .white
            navigationItem.leftBarButtonItem = backButton
        } else {
            super.viewWillAppear(animated)
        }
        let infoButton = UIButton(type: .infoLight)
        infoButton.tintColor = style == .blue ? .white : .black
        infoButton.addTarget(self, action: #selector(infoTapped), for: .touchUpInside)
        let rightBarItem = UIBarButtonItem(customView: infoButton)
        navigationItem.rightBarButtonItem = rightBarItem
    }
    
    // MARK: - Setup

    fileprivate func setupView() {
        [digit0, digit1, digit2, digit3, digit4, digit5].forEach {
            $0?.backgroundColor = AppStyle.lightestGrey
            $0?.layer.cornerRadius = 10.0
        }
        switch state {
        case .creating:
            subtitleLabel?.text = "Enter a new passcode"
        case .entering:
            subtitleLabel?.text = "Enter your passcode to continue"
        case .confirming:
            subtitleLabel?.text = "Confirm passcode"
        }
    }
    
    fileprivate func setupKeyboard() {
        collectionView?.delegate = self
        collectionView?.dataSource = self
        let nib = UINib(nibName: NumpadCollectionViewCell.identifier, bundle: nil)
        collectionView?.register(nib, forCellWithReuseIdentifier: NumpadCollectionViewCell.identifier)
        collectionView?.backgroundColor = .clear
        collectionView?.isScrollEnabled = false
        guard let collectionView = collectionView else { return }
        let cellSize = CGSize(width: collectionView.bounds.width / cols - 1, height: collectionView.bounds.height / rows)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = cellSize
        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        layout.minimumLineSpacing = 1.0
        layout.minimumInteritemSpacing = 1.0
        collectionView.collectionViewLayout = layout
    }
    
    override func setupNavBar() {
        super.setupNavBar()
        navigationItem.backBarButtonItem?.tintColor = style == .blue ? .white : .black
    }
    
    // MARK: - Actions
    
    @objc fileprivate func infoTapped() {
        let alertController = UIAlertController(title: "Passcode Info", message: "A passcode is required to prevent unauthorized users from accessing your funds.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true)
    }
    
    @objc fileprivate func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Methods
    
    fileprivate func handleInput() {
        guard let inputData = passcode.data(using: .utf8),
            let inputSalt = Sodium().genericHash.hash(message: inputData) else { return }
        switch state {
        case .creating:
            tempPasscode = passcode
            state = .confirming
        case .entering:
            let authenticated = inputSalt.hexString == Keychain.standard.get(key: KeychainKey.passcodeSalt)?.hexString
            if action == .reset, authenticated {
                state = .creating
            } else if authenticated {
                isAuthenticated = true
                onAuthenticated?()
            } else {
                if WalletManager.shared.unlockFailed() {
                    WalletManager.shared.lockWallet()
                    // Lock wallet for 30 min
                    onLock?()
                    return
                }
                let remaining = Keychain.standard.get(key: KeychainKey.allowedFailAttempts)?.uint32 ?? 10
                resetKeyboard()
                Banner.show("Incorrect passcode (\(remaining) remaining attempts)", style: .danger)
            }
        case .confirming:
            if passcode == tempPasscode {
                Keychain.standard.set(value: inputSalt, key: KeychainKey.passcodeSalt)
                Lincoln.log("Encrypted passcode saved", inConsole: true)
                isAuthenticated = true
                onAuthenticated?()
            } else {
                Banner.show("Passcodes do not match", style: .danger)
                resetKeyboard()
            }
        }
    }
    
    fileprivate func resetKeyboard() {
        passcode = ""
        [digit0, digit1, digit2, digit3, digit4, digit5].forEach {
            $0?.backgroundColor = AppStyle.lightestGrey
        }
    }
}

extension PasscodeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}

extension PasscodeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        // Ignore bottom left cell in keyboard
        return indexPath.item != 9
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Ignore empty button
        if indexPath.item == 9 { return }
        if indexPath.item == 11 {
            // Backspace
            guard passcode.count > 0 else { return }
            passcode = String(passcode.prefix(passcode.count - 1))
        } else if passcode.count < 6 {
            let key = indexPath.item == 10 ? 0 : indexPath.item + 1
            passcode += "\(key)"
        } else {
            return
        }
        [digit0, digit1, digit2, digit3, digit4, digit5].enumerated().forEach { (index, item) in
            if index < passcode.count {
                item?.backgroundColor = style == .blue ? .white : .black
            } else {
                item?.backgroundColor = AppStyle.lightestGrey
            }
        }
        if passcode.count == 6 {
            handleInput()
        }
    }
}

extension PasscodeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NumpadCollectionViewCell.identifier, for: indexPath) as? NumpadCollectionViewCell else { return UICollectionViewCell() }
        if indexPath.item < 9 {
            cell.valueLabel?.text = "\(indexPath.item + 1)"
        } else if indexPath.item == 9 {
            cell.valueLabel?.text = ""
        } else if indexPath.item == 10 {
            cell.valueLabel?.text = "0"
        } else if indexPath.item == 11 {
            cell.valueImageView?.image = #imageLiteral(resourceName: "backspace").withRenderingMode(.alwaysTemplate)
            cell.valueImageView?.tintColor = style == .blue ? .white : AppStyle.lowAlphaBlack
        }
        cell.valueLabel?.textColor = style == .blue ? .white : AppStyle.lowAlphaBlack
        return cell
    }
}
