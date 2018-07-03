//
//  AddressBookCoordinator.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 1/23/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import UIKit

protocol AddressBookCoordinatorDelegate: class {
    func entrySelected(_ entry: AddressEntry, coordinator: Coordinator)
    func closeTapped(coordinator: AddressBookCoordinator)
}

class AddressBookCoordinator: RootViewCoordinator {
    var childCoordinators: [Coordinator] = []
    var rootViewController: UIViewController
    weak var delegate: AddressBookCoordinatorDelegate?
    fileprivate var navigationController: UINavigationController?
    fileprivate var addressBookVC: AddressBookViewController
    fileprivate var dismissOnSelect: Bool
    
    init(root: UIViewController, dismissOnSelect: Bool = true) {
        self.rootViewController = root
        self.dismissOnSelect = dismissOnSelect
        addressBookVC = AddressBookViewController()
    }
    
    func start() {
        addressBookVC.delegate = self
        navigationController = UINavigationController(rootViewController: addressBookVC)
        rootViewController.present(navigationController!, animated: true)
    }
}

extension AddressBookCoordinator: AddressBookViewControllerDelegate {
    func editAddressTapped(_ entry: AddressEntry) {
        let viewModel = EnterAddressEntryViewModel(title: "Edit Entry", name: entry.name, address: entry.address, isEditing: true)
        let enterVC = EnterAddressEntryViewController(with: viewModel)
        enterVC.onAddressSaved = { _ in
            self.addressBookVC.reload()
            self.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(enterVC, animated: true)
    }
    
    func newAddressTapped() {
        let viewModel = EnterAddressEntryViewModel(title: .localize("new-entry"))
        let enterVC = EnterAddressEntryViewController(with: viewModel)
        enterVC.onAddressSaved = { [weak self] _ in
            self?.addressBookVC.reload()
            self?.navigationController?.popViewController(animated: true)
        }
        
        navigationController?.pushViewController(enterVC, animated: true)
    }
    
    func closeTapped() {
        addressBookVC.dismiss(animated: true)
        delegate?.closeTapped(coordinator: self)
    }
    
    func entrySelected(_ entry: AddressEntry) {
        // Propogate address up to parent coordinator
        if dismissOnSelect {
            addressBookVC.dismiss(animated: true)
            delegate?.entrySelected(entry, coordinator: self)
        } else {
            let viewModel = EnterAddressEntryViewModel(title: "Edit Entry", name: entry.name, address: entry.address, isEditing: true)
            let editVC = EnterAddressEntryViewController(with: viewModel)
            editVC.onAddressSaved = { [weak self] _ in
                self?.addressBookVC.reload()
                self?.navigationController?.popViewController(animated: true)
            }
            navigationController?.pushViewController(editVC, animated: true)
        }
    }
}
