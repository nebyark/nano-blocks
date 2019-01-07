//
//  AccountsViewController.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 1/3/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import UIKit

protocol AccountsViewControllerDelegate: class {
    func settingsTapped()
    func accountTapped(_ account: AccountInfo)
    func accountAdded()
}

class AccountsViewController: UIViewController {

    @IBOutlet weak var currencyTapBox: UIView?
    @IBOutlet weak var sortButton: UIButton?
    @IBOutlet weak var totalBalanceTitleLabel: UILabel?
    @IBOutlet weak var totalBalanceLabel: UILabel?
    @IBOutlet weak var unitsLabel: UILabel?
    @IBOutlet weak var tableView: UITableView?
    weak var delegate: AccountsViewControllerDelegate?
    private(set) var viewModel: AccountsViewModel = AccountsViewModel()
    fileprivate(set) var customInteractor: CustomInteractor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
        setupNavBar()
        navigationController?.delegate = self

        WalletManager.shared.accounts.forEach { account in
            self.fetchAccountInfo(for: account)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.updateAccounts()
    }
    
    // MARK: - Setup
    
    fileprivate func setupNavBar() {
        let leftBarItem = UIBarButtonItem(image: #imageLiteral(resourceName: "nav_settings"), style: .plain, target: self, action: #selector(settingsTapped))
        leftBarItem.tintColor = .white
        navigationItem.leftBarButtonItem = leftBarItem
        
        let rightBarItem = UIBarButtonItem(image: #imageLiteral(resourceName: "nav_plus"), style: .plain, target: self, action: #selector(plusTapped))
        rightBarItem.tintColor = .white
        navigationItem.rightBarButtonItem = rightBarItem
    }
    
    fileprivate func setupTableView() {
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.estimatedRowHeight = 80
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.register(AccountTableViewCell.self)
        tableView?.tableFooterView = UIView()
        tableView?.separatorStyle = .none
    }
    
    fileprivate func setupView() {
        assert(navigationController?.view != nil, "View should be presented in a nav controller")
        guard let nav = navigationController else { return }
        let bgImage: UIImageView = {
            let iv = UIImageView(frame: nav.view.bounds)
            iv.image = #imageLiteral(resourceName: "xrb_bg_2b3165").withRenderingMode(.alwaysOriginal)
            iv.contentMode = .scaleAspectFill
            return iv
        }()
        view.backgroundColor = .clear
        let bgView = UIView(frame: nav.view.bounds)
        bgView.backgroundColor = UIColor(rgb: 43, green: 49, blue: 101, alpha: 1.0)
        nav.view.insertSubview(bgView, at: 0)
        nav.view.insertSubview(bgImage, at: 1)
        let buttonImg = #imageLiteral(resourceName: "down").withRenderingMode(.alwaysTemplate)
        sortButton?.tintColor = .white
        sortButton?.setTitle(String.localize("accounts").uppercased(), for: .normal)
        sortButton?.isUserInteractionEnabled = false
        sortButton?.setImage(buttonImg, for: .normal)
        
        let currencyTap = UITapGestureRecognizer(target: self, action: #selector(currencySwitch))
        currencyTapBox?.addGestureRecognizer(currencyTap)
        totalBalanceTitleLabel?.text = String.localize("total-balance").uppercased()
    }
    
    // MARK: - Actions

    private func fetchAccountInfo(for account: AccountInfo) {
        guard let address = account.address else { return }
        NetworkAdapter.getLedger(account: address) { [weak self] info in
            if let info = info {
                PersistentStore.write {
                    account.copyProperties(from: info)
                }
                self?.updateAccounts()
            }
        }
    }

    private func updateAccounts() {
        WalletManager.shared.updateAccounts()
        tableView?.reloadData()
        viewModel = AccountsViewModel()
        totalBalanceLabel?.text = viewModel.balanceValue
        unitsLabel?.text = viewModel.currencyValue
    }

    @objc func settingsTapped() {
        delegate?.settingsTapped()
    }
    
    @objc func plusTapped() {
        self.showTextDialogue(.localize("add-account"), placeholder: "Account name", keyboard: .default, completion: { [weak self] (textField) in
            guard let text = textField.text, !text.isEmpty else {
                Banner.show(.localize("no-account-name-provided"), style: .warning)
                return
            }
            WalletManager.shared.addAccount(name: text)
            self?.delegate?.accountAdded()
            self?.tableView?.reloadData()
            self?.setupNavBar()

            if let account = WalletManager.shared.accounts.last {
                self?.fetchAccountInfo(for: account)
            }
        })
    }
    
    @objc func currencySwitch() {
        viewModel.toggleCurrency()
        tableView?.reloadData()
        totalBalanceLabel?.text = viewModel.balanceValue
        unitsLabel?.text = viewModel.currencyValue
    }
}

extension AccountsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return WalletManager.shared.accounts.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(AccountTableViewCell.self, for: indexPath)
        let account = WalletManager.shared.account(at: indexPath.section)
        cell.prepare(with: account, useSecondaryCurrency: Currency.isSecondarySelected)
        return cell
    }
}

extension AccountsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let account = WalletManager.shared.account(at: indexPath.section) else { return }
        delegate?.accountTapped(account)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
}

extension AccountsViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        customInteractor = CustomInteractor(attachTo: toVC)
        return TransparentNavigationTransition(operation: operation)
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let ci = customInteractor else { return nil }
        return ci.transitionInProgress ? customInteractor : nil
    }
}
