//
//  CurrencySelectViewController.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 2/10/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import UIKit

class CurrencySelectViewController: TransparentNavViewController {

    @IBOutlet weak var tableView: UITableView!
    fileprivate let viewModel = CurrencySelectViewModel()
    var onCurrencySelect: ((Currency, Double) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.setupNavBar()
        setupTableView()
    }
    
    // MARK: - Setup
    
    fileprivate func setupTableView() {
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        tableView?.tableFooterView = UIView()
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: "curr-cell")
    }
}

extension CurrencySelectViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let currency = viewModel[indexPath.row] else { return }
        CurrencyAPI.getCurrencyInfo(for: currency) { (rate) in
            guard let rate = rate else {
                Banner.show("Error fetching currency info for \(currency.rawValue.uppercased())", style: .danger)
                return }
            self.onCurrencySelect?(currency, rate)
        }
    }
}

extension CurrencySelectViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "curr-cell", for: indexPath)
        guard let currency = viewModel[indexPath.row] else { return UITableViewCell() }
        cell.textLabel?.text = currency.rawValue.uppercased() + " (\(currency.symbol))"
        cell.separatorInset = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 0)
        cell.accessoryType = Currency.secondary == currency ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.currencies.count
    }
}
