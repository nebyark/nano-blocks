//
//  AppCoordinator.swift
//
//  Created by Ben Kray on 6/1/17.
//  Copyright © 2017 Planar Form. All rights reserved.
//

import UIKit
import LocalAuthentication

class AppCoordinator: NSObject, RootViewCoordinator {
    static let shared: AppCoordinator = AppCoordinator()
    var childCoordinators: [Coordinator] = []
    var rootViewController: UIViewController {
        return navController
    }
    private(set) var navController: UINavigationController
    
    // MARK: - Initializers 
    
    override init() {
        self.navController = UINavigationController()
        super.init()
        setupNav()
    }
    
    func start() {
        guard !WalletManager.shared.isLocked else {
            navController.pushViewController(LockViewController(), animated: true)
            return
        }
        NetworkAdapter.getVerifiedReps { (accounts) in
            WalletManager.shared.setRepList(accounts)
        }
        if WalletManager.shared.accounts.count < 1 {
            showStart()
        } else {
            if UserSettings.requireBiometricseOnLaunch {
                handleBiometrics()
            } else {
                handlePassword()
            }
        }
    }
    
    fileprivate func handlePassword() {
        let passwordVC = PasswordViewController(action: .authenticate, style: .blue, hideNav: true)
        passwordVC.onAuthenticated = { [weak self] (_) in
            self?.navController.popViewController(animated: true)
            self?.showWallet()
        }
        navController.pushViewController(passwordVC, animated: true)
    }
    
    fileprivate func handleBiometrics() {
        let context = LAContext()
        var error: NSError? = NSError()
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Authorization is required to proceed", reply: { (success, err) in
                guard success else {
                    DispatchQueue.main.async {
                        self.handlePassword()
                    }
                    return
                }
                guard WalletManager.shared.unlockWalletBiometrics() else { return }
                DispatchQueue.main.async {
                    self.showWallet()
                }
            })
        }
    }
    
    fileprivate func setupNav() {
        let bgImage: UIImageView = {
            let iv = UIImageView(frame: navController.view.bounds)
            iv.image = #imageLiteral(resourceName: "xrb_bg_2b3165").withRenderingMode(.alwaysOriginal)
            iv.contentMode = .scaleAspectFill
            return iv
        }()
        navController.view.backgroundColor = .clear
        let bgView = UIView(frame: navController.view.bounds)
        bgView.backgroundColor = UIColor(rgb: 43, green: 49, blue: 101, alpha: 1.0)
        navController.view.insertSubview(bgView, at: 0)
        navController.view.insertSubview(bgImage, at: 1)
    }
    
    fileprivate func showDisclaimer() {
        let vc = DisclaimerViewController()
        vc.modalPresentationStyle = .overCurrentContext
        vc.onDecision = { [weak self] didAccept in
            if didAccept {
                UserDefaults.standard.set(true, forKey: "disclaimer-accepted")
                UserDefaults.standard.synchronize()
                vc.dismiss(animated: true)
                self?.showWallet()
            } else {
                exit(1)
            }
        }
        navController.present(vc, animated: true)
    }
    
    fileprivate func showWallet() {
        navController.viewControllers = []
        guard UserDefaults.standard.bool(forKey: "disclaimer-accepted") else {
            showDisclaimer()
            return
        }
        
        let accountsCoordinator = AccountsCoordinator(root: rootViewController)
        accountsCoordinator.delegate = self
        addChildCoordinator(accountsCoordinator)
        accountsCoordinator.start()
    }
    
    fileprivate func showStart() {
        navController.viewControllers = []
        let createWalletCoordinator = CreateWalletCoordinator(root: rootViewController)
        createWalletCoordinator.delegate = self
        addChildCoordinator(createWalletCoordinator)
        createWalletCoordinator.start()
    }
}

extension AppCoordinator: AccountsCoordinatorDelegate {
    func walletCleared(coordinator: AccountsCoordinator) {
        removeChildCoordinator(coordinator)
        showStart()
    }
}

extension AppCoordinator: CreateWalletCoordinatorDelegate {
    func closeTapped(coordinator: CreateWalletCoordinator) {
        removeChildCoordinator(coordinator)
    }
    
    func walletCreated(coordinator: CreateWalletCoordinator) {
        removeChildCoordinator(coordinator)
        showWallet()
    }
}
