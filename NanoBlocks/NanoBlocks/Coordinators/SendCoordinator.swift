//
//  SendCoordinator.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 1/21/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import UIKit
import StoreKit

protocol SendCoordinatorDelegate: class {
    func sendBlockGenerated(coordinator: Coordinator)
    func sendComplete(coordinator: Coordinator)
    func closeTapped(coordinator: Coordinator)
}

class SendCoordinator: RootViewCoordinator {
    var childCoordinators: [Coordinator] = []
    var rootViewController: UIViewController
    fileprivate var sendViewController: SendViewController
    private(set) var account: AccountInfo
    weak var delegate: SendCoordinatorDelegate?
    
    init(root: UIViewController, account: AccountInfo) {
        self.rootViewController = root
        self.sendViewController = SendViewController(account: account)
        self.account = account
    }
    
    func start() {
        sendViewController.delegate = self
        sendViewController.modalPresentationStyle = .overFullScreen
        sendViewController.delegate = self
        rootViewController.present(sendViewController, animated: true)
    }
}


extension SendCoordinator: SendViewControllerDelegate {
    func enterAddressTapped() {
        let enterAddressVC = EnterAddressViewController()
        enterAddressVC.onSelect = { [weak self] (entry) in
            self?.sendViewController.apply(entry: entry)
        }
        enterAddressVC.modalTransitionStyle = .crossDissolve
        sendViewController.present(UINavigationController(rootViewController: enterAddressVC), animated: true)
    }
    
    func enterAmountTapped() {
        let enterAmountVC = EnterAmountViewController(with: account)
        enterAmountVC.enteredAmount = { [weak self] (amount) in
            self?.sendViewController.apply(amount: amount)
        }
        enterAmountVC.modalTransitionStyle = .crossDissolve
        sendViewController.present(UINavigationController(rootViewController: enterAmountVC), animated: true)
    }
    
    func sendTapped(txInfo: TxInfo) {
        let confirmVC = ConfirmTxViewController(with: txInfo)
        confirmVC.modalTransitionStyle = .crossDissolve
        confirmVC.onSendComplete = { [weak self] in
            guard let me = self else {
                return
            }
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            }
            me.rootViewController.dismiss(animated: true)
            me.delegate?.sendComplete(coordinator:  me)
        }
        sendViewController.present(UINavigationController(rootViewController: confirmVC), animated: true)
    }
    
    func closeTapped() {
        delegate?.closeTapped(coordinator: self)
    }
    
    func scanTapped() {
        let qrVC = QRScanViewController()
        qrVC.onQRCodeScanned = { [weak self] (result) in
            self?.sendViewController.apply(scanResult: result)
        }
        sendViewController.present(UINavigationController(rootViewController: qrVC), animated: true)
    }
    
    func addressBookTapped() {
        let addressCoordinator = AddressBookCoordinator(root: sendViewController)
        addressCoordinator.delegate = self
        addressCoordinator.start()
        childCoordinators.append(addressCoordinator)
    }
}

extension SendCoordinator: AddressBookCoordinatorDelegate {
    func entrySelected(_ entry: AddressEntry, coordinator: Coordinator) {
        sendViewController.apply(entry: entry)
        removeChildCoordinator(coordinator)
    }
    
    func closeTapped(coordinator: AddressBookCoordinator) {
        removeChildCoordinator(coordinator)
    }
}
