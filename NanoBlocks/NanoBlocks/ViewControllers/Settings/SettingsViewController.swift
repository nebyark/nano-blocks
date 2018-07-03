//
//  SettingsViewController.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 2/6/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import UIKit

protocol SettingsViewControllerDelegate: class {
    func closeTapped()
    func currencyTapped()
    func consoleTapped()
    func securityTapped()
    func addressBookTapped()
    func clearWalletTapped()
    func aboutTapped()
}

class SettingsViewController: TitleTableViewController {
    enum Rows: Int, CaseCountable {
        case currency
        case addressBook
        case console
        case security
        case about
        case clearData
        
        var title: String {
            switch self {
            case .clearData: return .localize("clear-wallet-data")
            case .addressBook: return .localize("address-book")
            case .console: return .localize("console")
            case .currency: return .localize("currency")
            case .security: return .localize("security")
            case .about: return .localize("about")
            }
        }
        static var caseCount: Int = Rows.countCases()
    }
    
    weak var delegate: SettingsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.isHidden = false
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - Setup
    
    override func setupNavBar() {
        let leftBarItem = UIBarButtonItem(image: #imageLiteral(resourceName: "close2").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(dismissTapped))
        navigationItem.leftBarButtonItem = leftBarItem
    }
    
    fileprivate func setupTableView() {
        tableView.register(SettingsTableViewCell.self)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - Actions
    
    fileprivate func handleClearWalletData() {
        self.delegate?.clearWalletTapped()
    }
    
    @objc func dismissTapped() {
        delegate?.closeTapped()
    }
}

extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let row = Rows(rawValue: indexPath.row) else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(SettingsTableViewCell.self, for: indexPath)
        cell.settingsTitleLabel?.text = row.title
        if row == .currency {
            let secondary = Currency.secondary
            cell.valueLabel?.text = "\(Currency.secondaryConversionRate.chopDecimal(to: secondary.precision)) \(secondary.rawValue.uppercased())"
        }
        cell.settingsTitleLabel?.textColor = row == .clearData ? .red : .black
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Rows.caseCount
    }
}

extension SettingsViewController: UITableViewDelegate {    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let row = Rows(rawValue: indexPath.row) else { return }
        switch row {
        case .currency:
            delegate?.currencyTapped()
        case .addressBook:
            delegate?.addressBookTapped()
        case .console:
            delegate?.consoleTapped()
        case .clearData:
            handleClearWalletData()
        case .security:
            delegate?.securityTapped()
        case .about:
            delegate?.aboutTapped()
        }
    }
}
