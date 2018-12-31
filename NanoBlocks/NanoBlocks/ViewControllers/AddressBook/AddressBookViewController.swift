//
//  AddressBookViewController.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 1/23/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import UIKit

protocol AddressBookViewControllerDelegate: class {
    func newAddressTapped()
    func editAddressTapped(_ entry: AddressEntry)
    func closeTapped()
    func entrySelected(_ entry: AddressEntry)
}

class AddressBookViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var headerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchTextField: UITextField?
    @IBOutlet weak var headerView: UIView?
    @IBOutlet weak var tableView: UITableView?
    fileprivate let headerHeight: CGFloat = 100.0
    fileprivate var viewModel: AddressBookViewModel = AddressBookViewModel()
    fileprivate var previousContentOffset: CGFloat = 0.0
    weak var delegate: AddressBookViewControllerDelegate?
    var shouldDismissOnSelect: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            // safe area by default
        } else {
            // XIB file hack for backwards compatibilty
            headerView?.topAnchor.constraint(equalTo: view.topAnchor, constant: 60).isActive = true
        }
        setupView()
        setupNavBar()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - Setup
    
    fileprivate func setupView() {
        titleLabel?.text = .localize("address-book")
        searchTextField?.layer.cornerRadius = 17.5
        searchTextField?.leftView = {
           let imageView = UIImageView(frame: CGRect(x: 10, y: 0, width: 15, height: 15))
            imageView.tintColor = AppStyle.lightGrey
            imageView.image = #imageLiteral(resourceName: "search_temp").withRenderingMode(.alwaysTemplate)
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 15))
            paddingView.addSubview(imageView)
            return paddingView
        }()
        searchTextField?.leftViewMode = .always
        searchTextField?.autocorrectionType = .no
        searchTextField?.autocapitalizationType = .none
        searchTextField?.clearButtonMode = .whileEditing
        searchTextField?.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        searchTextField?.placeholder = .localize("search")
    }
    
    fileprivate func setupNavBar() {
        let leftBarItem = UIBarButtonItem(image: #imageLiteral(resourceName: "close2").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(dismissTapped))
        navigationItem.leftBarButtonItem = leftBarItem
        let rightBarItem = UIBarButtonItem(image: #imageLiteral(resourceName: "settings_pencil").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(editTapped))
        navigationItem.rightBarButtonItem = rightBarItem
    }
    
    fileprivate func setupTableView() {
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.tableFooterView = UIView()
        tableView?.estimatedRowHeight = 55.0
        tableView?.allowsSelectionDuringEditing = true
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.register(AddressItemTableViewCell.self)
    }
    
    // MARK: - Actions
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        viewModel.filter(with: textField.text ?? "")
        
        if (textField.text == "") {
            viewModel.resetFilter()
        }
        tableView?.reloadData()

    }
    
    @objc func editTapped() {
        tableView?.setEditing(true, animated: true)
        let rightBarItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        rightBarItem.tintColor = .black
        navigationItem.rightBarButtonItem = rightBarItem
    }
    
    @objc func doneTapped() {
        tableView?.setEditing(false, animated: true)
        let rightBarItem = UIBarButtonItem(image: #imageLiteral(resourceName: "settings_pencil").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(editTapped))
        navigationItem.rightBarButtonItem = rightBarItem
    }
    
    @objc func dismissTapped() {
        delegate?.closeTapped()
    }
    
    @IBAction func plusTapped(_ sender: Any) {
        self.delegate?.newAddressTapped()
    }
    
    fileprivate func handleSelect(_ indexPath: IndexPath) {
        if let entry = viewModel[indexPath.row] {
            delegate?.entrySelected(entry)
        }
    }
    
    func reload() {
        viewModel.updateData()
        tableView?.reloadData()
    }
}

extension AddressBookViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
        let currentOffset = min(max(scrollView.contentOffset.y, 0), scrollView.contentSize.height - scrollView.bounds.size.height)
        if currentOffset > 0 {
            let delta: CGFloat = previousContentOffset - currentOffset
            headerTopConstraint.constant += delta
            if headerTopConstraint.constant < -headerHeight {
                headerTopConstraint.constant = -headerHeight
                UIView.animate(withDuration: 0.2) {
                    self.title = String.localize("address-book")
                }
            } else if headerTopConstraint.constant > 0 {
                headerTopConstraint.constant = 0
            }
            view.layoutIfNeeded()
            previousContentOffset = currentOffset
        } else {
            previousContentOffset = 0
            headerTopConstraint.constant = 0
            view.layoutIfNeeded()
        }
        if headerTopConstraint.constant == 0 {
            UIView.animate(withDuration: 0.2) {
                self.title = nil
            }
        }
    }
}

extension AddressBookViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView.isEditing {
            guard let entry = viewModel[indexPath.row] else { return }
            delegate?.editAddressTapped(entry)
        } else {
            handleSelect(indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.removeEntry(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension AddressBookViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredEntries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let accountEntry = viewModel[indexPath.row] else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(AddressItemTableViewCell.self, for: indexPath)
        cell.nameLabel?.text = accountEntry.name
        cell.addressLabel?.text = accountEntry.address
        if WalletManager.shared.accounts.contains(where: {$0.address == accountEntry.address }) {
            cell.iconImageView?.isHidden = false
        } else {
            cell.iconImageView?.isHidden = true
        }
        
        return cell
    }
}
