//
//  SettingsCoordinator.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 2/6/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import UIKit

class SettingsCoordinator: RootViewCoordinator {
    var childCoordinators: [Coordinator] = []
    var rootViewController: UIViewController
    fileprivate var navController: UINavigationController = UINavigationController()
    
    /// Bool prop is whether or not the dismiss should also clear app data
    var onDismiss: ((Coordinator, Bool) -> Void)?
    
    init(root: UIViewController) {
        self.rootViewController = root
    }
    
    func start() {
        let settingsVC = SettingsViewController(title: .localize("settings"))
        settingsVC.delegate = self
        navController.viewControllers = [settingsVC]
        rootViewController.present(navController, animated: true)
    }
}

extension SettingsCoordinator: SettingsViewControllerDelegate {
    func aboutTapped() {
        navController.pushViewController(AboutViewController(title: .localize("about")), animated: true)
    }
    
    func securityTapped() {
        let securityVC = SecurityViewController(title: .localize("security"))
        securityVC.onChangePasswordTapped = { [weak self] in
            let passwordVC = PasswordViewController(action: .authenticate, style: .white, hideNav: false)
            passwordVC.onAuthenticated = { (oldPw) in
                let resetVC = PasswordViewController(action: .reset, style: .white, hideNav: false)
                resetVC.onAuthenticated = { (pw) in
                    guard WalletManager.shared.setWalletPassword(pw, oldPassword: oldPw) else {
                        Banner.show("Error when encrypting wallet with new password", style: .danger)
                        return
                    }
                    self?.navController.popViewController(animated: true)
                    self?.navController.popViewController(animated: true)
                    Banner.show("Wallet password has been changed", style: .success)
                }
                self?.navController.pushViewController(resetVC, animated: true)
            }
            self?.navController.pushViewController(passwordVC, animated: true)
        }
        
        securityVC.onShowSeedTapped = { [weak self] in
            let passwordVC = PasswordViewController(action: .authenticate, style: .white, hideNav: false)
            passwordVC.onAuthenticated = { (pw) in
                guard let seed = WalletManager.shared.unlockWalletImpl(pw) else { return }
                let seedVC = SeedViewController(action: .showSeed, style: .white, seed: seed)
                self?.navController.pushViewController(seedVC, animated: true)
            }
            self?.navController.pushViewController(passwordVC, animated: true)
        }
        navController.pushViewController(securityVC, animated: true)
    }
    
    func consoleTapped() {
        let consoleVC = ConsoleViewController()
        navController.pushViewController(consoleVC, animated: true)
    }
    
    func closeTapped() {
        navController.dismiss(animated: true)
        onDismiss?(self, false)
    }
    
    func addressBookTapped() {
        let addressCoordinator = AddressBookCoordinator(root: navController, dismissOnSelect: false)
        addressCoordinator.delegate = self
        childCoordinators.append(addressCoordinator)
        addressCoordinator.start()
    }
    
    func currencyTapped() {
        let currencyVC = CurrencySelectViewController()
        currencyVC.onCurrencySelect = { [weak self] (currency, rate) in
            currency.setAsSecondaryCurrency(with: rate)
            self?.navController.popViewController(animated: true)
        }
        navController.pushViewController(currencyVC, animated: true)
    }
    
    func clearWalletTapped() {
        let passwordVC = PasswordViewController(action: .authenticate, style: .white, hideNav: false)
        passwordVC.onAuthenticated = { [weak self] _ in
            WalletManager.shared.clearWalletData()
            Lincoln.clearLog()
            PersistentStore.clearAll()
            self?.navController.dismiss(animated: true) {
                guard let me = self else {
                    return
                }
                me.onDismiss?(me, true)
            }
        }
        
        let alertController = UIAlertController(title: .localize("clear-wallet-data-title"), message: .localize("clear-wallet-data-msg"), preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { (_) in
            self.navController.pushViewController(passwordVC, animated: true)
        }
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        self.navController.present(alertController, animated: true)
    }
}

extension SettingsCoordinator: AddressBookCoordinatorDelegate {
    func entrySelected(_ entry: AddressEntry, coordinator: Coordinator) {
        // No op
    }
    
    func closeTapped(coordinator: AddressBookCoordinator) {
        removeChildCoordinator(coordinator)
    }
}
