//
//  AccountViewController.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 1/11/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import UIKit

protocol AccountViewControllerDelegate: class {
    func transactionTapped(txInfo: SimpleBlockBridge)
    func editRepTapped(account: AccountInfo)
    func sendTapped(account: AccountInfo)
    func receiveTapped(account: AccountInfo)
}

class AccountViewController: UIViewController {

    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var currencyTapBox: UIView?
    @IBOutlet weak var receiveButton: UIButton?
    @IBOutlet weak var sendButton: UIButton?
    @IBOutlet weak var sortButton: UIButton?
    @IBOutlet weak var totalBalanceTitleLabel: UILabel?
    @IBOutlet weak var totalBalanceLabel: UILabel?
    @IBOutlet weak var unitsLabel: UILabel?
    fileprivate var refreshControl: UIRefreshControl?
    @IBOutlet weak var tableView: UITableView!
    fileprivate var previousOffset: CGFloat = 0.0
    fileprivate var balanceToSortOffset: CGFloat?
    weak var delegate: AccountViewControllerDelegate?
    private(set) var viewModel: AccountViewModel
    
    init(account: AccountInfo) {
        self.viewModel = AccountViewModel(with: account)
        super.init(nibName: nil, bundle: nil)
        self.viewModel.onNewBlockBroadcasted = {
            self.onNewBlockBroadcasted()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if balanceToSortOffset == nil {
            balanceToSortOffset = totalBalanceLabel?.convert(totalBalanceLabel!.center, to: sortButton!).y ?? 1.0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.setupTableView()
        self.setupNavBar()
        self.viewModel.updateView = { [weak self] in
            self?.tableView.reloadData()
            self?.sortButton?.setTitle(self?.viewModel.refineType.title, for: .normal)
        }
        self.totalBalanceLabel?.text = self.viewModel.balanceValue.trimTrailingZeros()
        
        self.viewModel.getAccountInfo { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.viewModel.getHistory {
                strongSelf.tableView.reloadData()
            }
            // Case where history count is 0 means this account must first receive a send block to generate its open block. Otherwise, we can assume its a send block
            if strongSelf.viewModel.history.count > 0 {
                strongSelf.viewModel.getPending() { (pendingCount) in
                    guard pendingCount > 0 else { return }
                    var pendingStatus: String = .localize("arg-pending-receivables", arg: "\(pendingCount)")
                    if pendingCount < 2 {
                        pendingStatus = .localize("arg-pending-receivable", arg: "\(pendingCount)")
                    }
                    Banner.show(pendingStatus, style: .success)
                }
            }
            strongSelf.totalBalanceLabel?.text = self?.viewModel.balanceValue.trimTrailingZeros()
        }
    }

    // MARK: - Setup
    
    func setupNavBar() {
        view.viewWithTag(1337)?.removeFromSuperview()
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.tag = 1337
        stackView.axis = .vertical
        
        let accountNameLabel = UILabel()
        accountNameLabel.text = viewModel.account.name
        accountNameLabel.textColor = .white
        accountNameLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        
        let keyPair = WalletManager.shared.keyPair(at: viewModel.account.index)
        let accountAddressLabel = UILabel()
        accountAddressLabel.text = keyPair?.xrbAccount
        accountAddressLabel.lineBreakMode = .byTruncatingMiddle
        accountAddressLabel.textColor = UIColor.white.withAlphaComponent(0.4)
        accountAddressLabel.font = UIFont.systemFont(ofSize: 13, weight: .light)
        
        [accountNameLabel, accountAddressLabel].forEach {
            $0.textAlignment = .center
            $0.sizeToFit()
            $0.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview($0)
        }
        stackView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        stackView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        stackView.sizeToFit()
        navigationItem.titleView = stackView
        
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "back2"), style: .plain, target: self, action: #selector(backTapped))
        backButton.tintColor = .white
        navigationItem.leftBarButtonItem = backButton
        
        let rightBarItem = UIBarButtonItem(image: #imageLiteral(resourceName: "passphrase"), style: .plain, target: self, action: #selector(overflowPressed))
        rightBarItem.tintColor = .white
        navigationItem.rightBarButtonItem = rightBarItem
    }
    
    fileprivate func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(TransactionTableViewCell.self)
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = .white
        refreshControl?.addTarget(self, action: #selector(onPullDown(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    fileprivate func setupView() {
        let buttonImg = #imageLiteral(resourceName: "down").withRenderingMode(.alwaysTemplate)
        sortButton?.imageView?.tintColor = .white
        sortButton?.setImage(buttonImg, for: .normal)
        
        let currencyTap = UITapGestureRecognizer(target: self, action: #selector(currencySwitch))
        currencyTapBox?.addGestureRecognizer(currencyTap)
        totalBalanceTitleLabel?.text = String.localize("total-balance").uppercased()
        sortButton?.setTitle(viewModel.refineType.title, for: .normal)
        sendButton?.setTitle(.localize("send"), for: .normal)
        receiveButton?.setTitle(.localize("receive"), for: .normal)
        unitsLabel?.text = self.viewModel.currencyValue
    }
    
    // MARK: - Actions
    
    @objc fileprivate func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func refineTapped(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let latestAction = UIAlertAction(title: .localize("latest-sort"), style: .default) { (_) in
            self.viewModel.refine(.latestFirst)
        }
        let oldestAction = UIAlertAction(title: .localize("oldest-sort"), style: .default) { (_) in
            self.viewModel.refine(.oldestFirst)
        }
        let smallestAction = UIAlertAction(title: .localize("smallest-sort"), style: .default) { (_) in
            self.viewModel.refine(.smallestFirst)
        }
        let largestAction = UIAlertAction(title: .localize("largest-sort"), style: .default) { (_) in
            self.viewModel.refine(.largestFirst)
        }
        let sendAction = UIAlertAction(title: .localize("sent-filter"), style: .default) { (_) in
            self.viewModel.refine(.sent)
        }
        let receiveAction = UIAlertAction(title: .localize("received-filter"), style: .default) { (_) in
            self.viewModel.refine(.received)
        }
        let cancelAction = UIAlertAction(title: .localize("cancel"), style: .cancel, handler: nil)
        [latestAction, oldestAction, smallestAction, largestAction, sendAction, receiveAction, cancelAction].forEach { alertController.addAction($0) }
        present(alertController, animated: true)
    }
    
    @objc fileprivate func currencySwitch() {
        viewModel.toggleCurrency()
        tableView?.reloadData()
        totalBalanceLabel?.text = viewModel.balanceValue.trimTrailingZeros()
        unitsLabel?.text = viewModel.currencyValue
    }
    
    @objc fileprivate func overflowPressed() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: .localize("cancel"), style: .cancel, handler: nil)
        let editName = UIAlertAction(title: .localize("edit-name"), style: .default) { (_) in
            self.showTextDialogue(.localize("edit-name"), placeholder: "Account name", keyboard: .default, completion: { (textField) in
                guard let text = textField.text, !text.isEmpty else {
                    Banner.show("No account name provided", style: .warning)
                    return
                }
                PersistentStore.write {
                    self.viewModel.account.name = textField.text
                }
                self.setupNavBar()
            })
        }
        let editRepresentative = UIAlertAction(title: .localize("edit-representative"), style: .default) { (_) in
            self.delegate?.editRepTapped(account: self.viewModel.account)
        }
        let repair = UIAlertAction(title: .localize("repair-account"), style: .default) { (_) in
            self.viewModel.repair() {
                self.tableView.reloadData()
            }
        }
        alertController.addAction(editName)
        alertController.addAction(editRepresentative)
        alertController.addAction(repair)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    @objc func onPullDown(_ refreshControl: UIRefreshControl) {
        guard !viewModel.isFetching else { return }
        refreshControl.beginRefreshing()
        getPendingAndHistory()
    }
    
    fileprivate func getPendingAndHistory(_ getPending: Bool = true) {
        guard viewModel.account.frontier != ZERO_AMT else {
            viewModel.getAccountInfo() {
                guard self.viewModel.account.pending > 0 else {
                    self.refreshControl?.endRefreshing()
                    return
                }
                self.getPendingAndHistory()
            }
            return
        }
        guard getPending else {
            self.viewModel.getHistory { [weak self] in
                self?.refreshControl?.endRefreshing()
                self?.tableView.reloadData()
            }
            return
        }
        self.viewModel.getPending { [weak self] (pendingCount) in
            if pendingCount > 0 {
                var pendingStatus: String = .localize("arg-pending-receivables", arg: "\(pendingCount)")
                if pendingCount < 2 {
                    pendingStatus = .localize("arg-pending-receivable", arg: "\(pendingCount)")
                }
                Banner.show(pendingStatus, style: .success)
            }
            self?.viewModel.getHistory {
                self?.refreshControl?.endRefreshing()
                self?.tableView.reloadData()
            }
        }
    }
    
    @IBAction func sendTapped(_ sender: Any) {
        delegate?.sendTapped(account: viewModel.account)
    }
    
    @IBAction func receiveTapped(_ sender: Any) {
        delegate?.receiveTapped(account: viewModel.account)
    }
    
    func onNewBlockBroadcasted() {
        self.viewModel.getAccountInfo { [weak self] in
            self?.totalBalanceLabel?.text = self?.viewModel.balanceValue.trimTrailingZeros()
            self?.getPendingAndHistory(false)
        }
    }
    
    func updateView() {
        tableView.reloadData()
    }
    
    func initiateChangeBlock(newRep: String?) {
        guard let rep = newRep,
            let keyPair = WalletManager.shared.keyPair(at: viewModel.account.index),
            let account = keyPair.xrbAccount else { return }
        if rep == viewModel.account.representative {
            Banner.show(.localize("no-rep-change"), style: .warning)
            return
        }
        guard viewModel.account.frontier != ZERO_AMT else {
            // No blocks have been made yet, store the rep for later
            PersistentStore.write {
                viewModel.account.representative = rep
            }
            Banner.show(.localize("rep-changed"), style: .success)
            return
        }
        var block = StateBlock(.change)
        block.previous = viewModel.account.frontier
        block.link = ZERO_AMT
        block.rawDecimalBalance = viewModel.account.balance.decimalNumber
        block.representative = rep
        guard block.build(with: keyPair) else { return }
        Banner.show("Waiting for work on change block...", style: .success)
        BlockHandler.handle(block, for: account) { [weak self] (result) in
            switch result {
            case .success(_):
                Banner.show(.localize("rep-changed"), style: .success)
                self?.viewModel.getAccountInfo() {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                Banner.show(.localize("change-rep-error-arg", arg: error.description), style: .danger)
            }
        }
    }
}

extension AccountViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let balanceToSortOffset = balanceToSortOffset else { return }
        let currentOffset = min(max(scrollView.contentOffset.y, 0), scrollView.contentSize.height - scrollView.bounds.size.height)
        let balanceY = totalBalanceLabel?.convert(totalBalanceLabel!.center, to: sortButton!).y ?? 1.0
        currencyTapBox?.alpha = CGFloat(balanceY / balanceToSortOffset)
        if currencyTapBox?.alpha ?? 0.0 < 0 { currencyTapBox?.alpha = 0 }
        if currencyTapBox?.alpha ?? 0.0 > 1 { currencyTapBox?.alpha = 1 }
        
        if currentOffset > 0 {
            let delta = previousOffset - currentOffset
            topConstraint.constant += delta
            if topConstraint.constant <= 0 {
                topConstraint.constant = 0
            } else if topConstraint.constant > 200 {
                topConstraint.constant = 200
            }
            previousOffset = currentOffset
        } else {
            topConstraint.constant = 200
            previousOffset = 0.0
        }
    }
}

extension AccountViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let tx = viewModel[indexPath.section] else { return }
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let copyAddress = UIAlertAction(title: "Copy Address", style: .default) { (_) in
            UIPasteboard.general.string = tx.account
            Banner.show("Address copied to clipboard", style: .success)
        }
        let viewDetails = UIAlertAction(title: "View Details", style: .default) { (_) in
            self.delegate?.transactionTapped(txInfo: tx)
        }
        let saveAddress = UIAlertAction(title: "Save Address", style: .default) { (_) in
            self.showTextDialogue(.localize("enter-name"), placeholder: .localize("name"), keyboard: .default, completion: { (textField) in
                guard let text = textField.text, !text.isEmpty else {
                    Banner.show(.localize("no-name-provided"), style: .warning)
                    return
                }
                PersistentStore.addAddressEntry(text, address: tx.account)
                Banner.show(.localize("arg-entry-saved", arg: text), style: .success)
            })
        }
        let cancel = UIAlertAction(title: .localize("cancel"), style: .cancel, handler: nil)
        actionSheet.addAction(viewDetails)
        actionSheet.addAction(copyAddress)
        if !PersistentStore.getAddressEntries().contains(where: {$0.address == tx.account }) {
            actionSheet.addAction(saveAddress)
        }
        actionSheet.addAction(cancel)
        DispatchQueue.main.async {
            self.present(actionSheet, animated: true)
        }
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

extension AccountViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(TransactionTableViewCell.self, for: indexPath)
        cell.prepare(with: viewModel[indexPath.section], useSecondaryCurrency: Currency.isSecondarySelected)
        return cell
    }
}
