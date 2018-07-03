//
//  PasswordViewController.swift
// NanoBlocks
//
//  Created by Ben Kray on 3/25/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import UIKit

enum PasscodeAction {
    case reset
    case create
    case authenticate
    case encrypt
}

class PasswordViewController: TransparentNavViewController {
    
    enum Style {
        case blue
        case white
    }
    
    fileprivate let style: Style
    fileprivate let hideNav: Bool
    var onAuthenticated: ((String) -> Void)?
    var onDismiss: (() -> Void)?
    var onLock: (() -> Void)?
    let action: PasscodeAction
    private var isAuthenticated: Bool = false
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var passwordTextField: UITextField?
    @IBOutlet weak var confirmPasswordTextField: UITextField?
    @IBOutlet weak var confirmPasswordView: UIView?
    @IBOutlet weak var passwordLabel: UILabel?
    @IBOutlet weak var confirmPasswordLabel: UILabel?
    @IBOutlet weak var line1: UIView?
    @IBOutlet weak var line2: UIView?
    
    init(action: PasscodeAction, style: Style, hideNav: Bool) {
        self.action = action
        self.hideNav = hideNav
        self.style = style
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if view.viewWithTag(420420) == nil {
            super.setupContinueButton(style == .blue ? .white : .black)
            continueButton?.tag = 420420
            continueButton?.addTarget(self, action: #selector(continuePressed), for: .touchDown)
            view.addSubview(continueButton!)
            continueButton?.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            // safe area by default
        } else {
            // XIB file hack for backwards compatibilty
            topConstraint.constant = 60
        }
        setupView()
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
        let rightBarItem = UIBarButtonItem(image: #imageLiteral(resourceName: "info").withRenderingMode(.alwaysTemplate), style: .done, target: self, action: #selector(infoTapped))
        rightBarItem.tintColor = style == .blue ? .white : .black
        navigationItem.rightBarButtonItem = rightBarItem
    }

    override func viewWillDisappear(_ animated: Bool) {
        if self.isMovingFromParentViewController && !isAuthenticated {
            // User is going back
            onDismiss?()
        }
    }
    
    // MARK: - Setup
    
    fileprivate func setupView() {
        if hideNav {
            view.alpha = 0.0
            UIView.animate(withDuration: 0.5) {
                self.view.alpha = 1.0
            }
        }
        if style == .blue {
            view.backgroundColor = .clear
            [titleLabel, passwordLabel, confirmPasswordLabel].forEach { $0?.textColor = .white }
            [passwordTextField, confirmPasswordTextField].forEach {
                $0?.textColor = .white
                $0?.isSecureTextEntry = true
            }
        } else {
            [passwordTextField, confirmPasswordTextField].forEach { $0?.isSecureTextEntry = true }
            [line1, line2].forEach { $0?.backgroundColor = .black }
        }
        
        switch action {
        case .authenticate:
            titleLabel?.text = .localize("authenticate")
            confirmPasswordView?.isHidden = true
        case .reset:
            titleLabel?.text = .localize("reset-password")
        case .create:
            titleLabel?.text = .localize("create-password")
        case .encrypt:
            titleLabel?.text = "Encrypt With"
            confirmPasswordView?.isHidden = true
        }
        passwordLabel?.text = String.localize("password").uppercased()
        confirmPasswordLabel?.text = String.localize("confirm-password").uppercased()
    }
    
    // MARK: - Actions
    
    @objc fileprivate func continuePressed() {
        switch action {
        case .create, .reset:
            guard let pw = passwordTextField?.text,
                let confirmPw = confirmPasswordTextField?.text,
                !pw.isEmpty, !confirmPw.isEmpty else {
                Banner.show(.localize("enter-password-both-field"), style: .warning)
                return
            }
            guard pw == confirmPw else {
                Banner.show(.localize("password-mismatch"), style: .danger)
                return
            }
            guard !PasswordChecker().isPasswordWeak(pw) else {
                Banner.show(.localize("top10k-weak-password"), style: .warning)
                return
            }
            isAuthenticated = true
            onAuthenticated?(pw)
        case .authenticate:
            guard let pw = passwordTextField?.text, !pw.isEmpty else {
                Banner.show(.localize("no-password-entered"), style: .warning)
                return
            }
            guard WalletManager.shared.unlockWallet(pw) else {
                Banner.show(.localize("unable-to-authenticate"), style: .danger)
                return
            }
            isAuthenticated = true
            onAuthenticated?(pw)
        case .encrypt:
            guard let pw = passwordTextField?.text, !pw.isEmpty else {
                Banner.show(.localize("no-password-entered"), style: .warning)
                return
            }
            isAuthenticated = true
            onAuthenticated?(pw)
        }
        
    }
    
    @objc fileprivate func infoTapped() {
        let alertController = UIAlertController(title: .localize("password-info"), message: .localize("password-info-msg"), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true)
    }
    
    @objc fileprivate func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}
