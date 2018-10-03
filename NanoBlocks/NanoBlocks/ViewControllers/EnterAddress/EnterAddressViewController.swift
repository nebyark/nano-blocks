//
//  EnterAddressViewController.swift
// NanoBlocks
//
//  Created by Ben Kray on 3/26/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import UIKit

class EnterAddressViewController: TransparentNavViewController {

    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var messageLabel: UILabel?
    @IBOutlet weak var searchTextField: UITextField?
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var inputXButton: UIButton?
    @IBOutlet weak var textView: UITextView?
    var viewModel = EnterAddressViewModel()
    var onSelect: ((AddressEntry) -> Void)?
    private let textViewPlaceholder = "Enter address"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        reloadView()
        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if view.viewWithTag(420420) == nil {
            super.setupContinueButton(.white)
            continueButton?.tag = 420420
            continueButton?.addTarget(self, action: #selector(continuePressed), for: .touchDown)
            continueButton?.setBackgroundImage(#imageLiteral(resourceName: "check_round").withRenderingMode(.alwaysTemplate), for: .normal)
            continueButton?.isEnabled = false
            view.addSubview(continueButton!)
            continueButton?.isHidden = false
            searchTextField?.becomeFirstResponder()
        }
    }
    
    // MARK: - Setup
    
    fileprivate func setupTableView() {
        tableView?.register(EnterAddressTableViewCell.self)
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.estimatedRowHeight = 50.0
        tableView?.separatorColor = AppStyle.lightGrey
        tableView?.isHidden = true
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.tableFooterView = UIView()
    }
    
    override func setupNavBar() {
        super.setupNavBar()
        let leftBarItem = UIBarButtonItem(image: #imageLiteral(resourceName: "close2").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(closeTapped))
        leftBarItem.tintColor = .white
        navigationItem.leftBarButtonItem = leftBarItem
        let pasteItem = UIBarButtonItem(image: #imageLiteral(resourceName: "clipboard2").withRenderingMode(.alwaysTemplate), style: .done, target: self, action: #selector(pasteTapped))
        pasteItem.tintColor = .white
        title = .localize("enter-address-title")
        navigationItem.rightBarButtonItem = pasteItem
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
    }
    
    fileprivate func setupView() {
        setupNavBar()
        setupSearch()
        inputXButton?.setBackgroundImage(#imageLiteral(resourceName: "input_x").withRenderingMode(.alwaysTemplate), for: .normal)
        inputXButton?.tintColor = AppStyle.lightGrey
        nameLabel?.textColor = AppStyle.lightGrey
        textView?.delegate = self
        self.textView?.text = self.textViewPlaceholder
        self.textView?.textColor = AppStyle.lightGrey
        messageLabel?.text = .localize("enter-address-search-msg")
    }
    
    fileprivate func setupSearch() {
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
    
    // MARK: - Actions
    
    fileprivate func reloadView() {
        guard let textView = self.textView, let tableView = self.tableView else {
            return
        }
        let isEmpty = textView.text.isEmpty || textView.text == self.textViewPlaceholder
        inputXButton?.isHidden = isEmpty || !tableView.isHidden
        nameLabel?.isHidden = isEmpty || !tableView.isHidden
        textView.isHidden = !tableView.isHidden

        continueButton?.isEnabled = WalletUtil.derivePublic(from: textView.text) != nil
        nameLabel?.text = viewModel.addressMap[textView.text] ?? .localize("unknown")
    }
    
    @IBAction func inputXTapped(_ sender: Any) {
        textView?.text = self.textViewPlaceholder
        textView?.textColor = AppStyle.lightGrey
        reloadView()
    }
    
    @objc fileprivate func continuePressed() {
        guard let address = textView?.text, let name = nameLabel?.text else { return }
        let entry = AddressEntry()
        entry.address = address
        entry.name = name
        onSelect?(entry)
        dismiss(animated: true)
    }
    
    @objc fileprivate func pasteTapped() {
        textView?.text = UIPasteboard.general.string
        textView?.textColor = .white
        reloadView()
    }
    
    @objc fileprivate func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        viewModel.filter(with: textField.text ?? "")
        
        if (textField.text == "") {
            viewModel.resetFilter()
        }
        tableView?.isHidden = textField.text == "" || textField.text == self.textViewPlaceholder || viewModel.filteredEntries.count == 0
        
        reloadView()
        tableView?.reloadData()
    }
    
}

extension EnterAddressViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}

extension EnterAddressViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let addressEntry = viewModel[indexPath.row] else { return }
        nameLabel?.text = addressEntry.name
        textView?.text = addressEntry.address
        textView?.textColor = .white
        searchTextField?.text = ""
        guard let tf = searchTextField else { return }
        textFieldDidChange(tf)
    }
}

extension EnterAddressViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = viewModel[indexPath.row] else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(EnterAddressTableViewCell.self, for: indexPath)
        cell.nameLabel?.text = item.name
        cell.addressLabel?.text = item.address
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.count
    }
}

extension EnterAddressViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == self.textViewPlaceholder {
            textView.text = ""
            textView.textColor = .white
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = self.textViewPlaceholder
            textView.textColor = AppStyle.lightGrey
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        reloadView()
    }
}
