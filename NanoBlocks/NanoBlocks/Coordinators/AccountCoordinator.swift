//
//  AccountCoordinator.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 1/31/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import UIKit

class AccountCoordinator: RootViewCoordinator {
    var childCoordinators: [Coordinator] = []
    var rootViewController: UIViewController
    private(set) var navController: UINavigationController
    fileprivate var accountVC: AccountViewController?
    let account: AccountInfo
    var onDismiss: ((Coordinator) -> Void)?
    
    init(in navController: UINavigationController, account: AccountInfo) {
        self.rootViewController = navController
        self.account = account
        self.navController = navController
    }
    
    func start() {
        accountVC = AccountViewController(account: account)
        accountVC?.delegate = self
        if let accountVC = accountVC {
            navController.pushViewController(accountVC, animated: true)
        }
    }
}

extension AccountCoordinator: AccountViewControllerDelegate {
    func sendTapped(account: AccountInfo) {
        Lincoln.log()
        let sendCoordinator = SendCoordinator(root: rootViewController, account: account)
        sendCoordinator.delegate = self
        childCoordinators.append(sendCoordinator)
        sendCoordinator.start()
    }
    
    func receiveTapped(account: AccountInfo) {
        Lincoln.log()
        let receiveCoordinator = ReceiveCoordinator(root: rootViewController, account: account)
        childCoordinators.append(receiveCoordinator)
        receiveCoordinator.onDismiss = { [weak self] (coordinator) in
            self?.removeChildCoordinator(coordinator)
        }
        receiveCoordinator.start()
    }
    
    func transactionTapped(txInfo: SimpleBlockBridge) {
        Lincoln.log()
        let blockInfoVC = BlockInfoViewController(viewModel: BlockInfoViewModel(with: txInfo))
        navController.pushViewController(blockInfoVC, animated: true)
    }
    
    func editRepTapped(account: AccountInfo) {
        Lincoln.log()
        let viewModel = EnterAddressEntryViewModel(title: .localize("edit-representative"), address: account.representative, isEditing: true, addressOnly: true)
        let editRepVC = EnterAddressEntryViewController(with: viewModel)
        editRepVC.onAddressSaved = { [weak self] (address) in
            self?.accountVC?.initiateChangeBlock(newRep: address)
        }
        rootViewController.present(UINavigationController(rootViewController: editRepVC), animated: true)
    }

    func backTapped() {
        navController.popViewController(animated: true)
        self.onDismiss?(self)
    }
}

extension AccountCoordinator: SendCoordinatorDelegate {
    func sendComplete(coordinator: Coordinator) {
        accountVC?.onNewBlockBroadcasted()
        removeChildCoordinator(coordinator)
    }
    
    func sendBlockGenerated(coordinator: Coordinator) {
        accountVC?.updateView()
        removeChildCoordinator(coordinator)
    }
    
    func closeTapped(coordinator: Coordinator) {
        removeChildCoordinator(coordinator)
    }
}
