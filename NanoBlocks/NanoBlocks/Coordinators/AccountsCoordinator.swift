//
//  AccountsCoordinator.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 1/11/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import UIKit

protocol AccountsCoordinatorDelegate: class {
    func walletCleared(coordinator: AccountsCoordinator)
}

class AccountsCoordinator: RootViewCoordinator {
    var childCoordinators: [Coordinator] = []
    var rootViewController: UIViewController
    private let navController = UINavigationController()
    weak var delegate: AccountsCoordinatorDelegate?
    private(set) var pubSubService: PubSubService?

    init(root: UIViewController) {
        self.rootViewController = root
    }
    
    func start() {
        let accountsVC = AccountsViewController()
        accountsVC.delegate = self
        navController.viewControllers = [accountsVC]
        navController.modalTransitionStyle = .crossDissolve
        rootViewController.present(navController, animated: true)
        
        setupPubSub()
    }
    
    fileprivate func setupPubSub() {
        // Client ID
        guard let idData = Keychain.standard.get(key: KeychainKey.mqttWalletID),
            let walletId = String(data: idData, encoding: .utf8) else { return }
        guard let username = Keychain.standard.get(key: KeychainKey.mqttUsername)?.hexString else { return }
        guard let pw = Keychain.standard.get(key: KeychainKey.mqttPassword)?.hexString else { return }
        pubSubService = PubSubService(clientID: walletId, username: username, pw: pw)
        pubSubService?.onConnect = { [weak self] in
            Lincoln.log("Connected to Canoe MQTT service...")
            self?.subscribeToAccounts()
        }
        pubSubService?.onIncomingBlock = { (incomingBlock) in
            // Make sure the block didn't originate from this wallet
            guard WalletManager.shared.accounts.filter({ $0.address == incomingBlock.account }).isEmpty else { return }
            // TODO: Handle incoming block
            guard let blockMeta = incomingBlock.meta() else { return }
            let account = WalletManager.shared.accounts.filter( { $0.address == blockMeta.link_as_account }).first
            Banner.show("Pending receivable for \(account?.name ?? "")", style: .success)
        }
    }
    
    fileprivate func subscribeToAccounts() {
        let accounts = WalletManager.shared.accounts.compactMap { $0.address }
        self.pubSubService?.subscribe(to: accounts)
    }
}

extension AccountsCoordinator: AccountsViewControllerDelegate {
    func accountAdded() {
        subscribeToAccounts()
    }
    
    func settingsTapped() {
        Lincoln.log()
        let settingsCoordinator = SettingsCoordinator(root: navController)
        settingsCoordinator.onDismiss = { [weak self] (coordinator, didClearWallet) in
            guard let me = self else { return }
            me.removeChildCoordinator(coordinator)
            if didClearWallet {
                // TODO: dismiss and take user to start
                me.navController.dismiss(animated: true)
                me.delegate?.walletCleared(coordinator: me)
            }
        }
        settingsCoordinator.start()
        childCoordinators.append(settingsCoordinator)
    }
    
    func accountTapped(_ account: AccountInfo) {
        Lincoln.log("Account at index \(account.index) tapped")
        let accountCoordinator = AccountCoordinator(in: navController, account: account)
        accountCoordinator.start()
        childCoordinators.append(accountCoordinator)
    }
}
