//
//  BlockInfoViewController.swift
// NanoBlocks
//
//  Created by Ben Kray on 4/22/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import UIKit
import SnapKit

class BlockInfoViewController: TransparentNavViewController {

    let viewModel: BlockInfoViewModel

    lazy var mainStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12.0
        stackView.distribution = .fill
        return stackView
    }()

    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = AppStyle.Font.body
        label.textColor = AppStyle.Color.lowAlphaWhite
        return label
    }()

    lazy var scrollView: UIScrollView = UIScrollView()
    
    init(viewModel: BlockInfoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        LoadingView.stopAnimating()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        buildView()
        LoadingView.startAnimating(in: self.navigationController, dimView: true)
        viewModel.fetch { [weak self] in
            self?.buildStackView()
            LoadingView.stopAnimating()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentInset = UIEdgeInsetsMake(0, 0, AppStyle.Size.padding, 0)
    }

    // MARK: - Setup
    
    fileprivate func buildView() {
        let typeLabel = UILabel()
        typeLabel.font = AppStyle.Font.title
        typeLabel.textColor = .white
        typeLabel.text = viewModel.info.type.capitalized(with: .current)
        view.addSubview(typeLabel)
        view.addSubview(dateLabel)
        view.addSubview(scrollView)

        let contentView = UIView()
        contentView.addSubview(mainStack)
        scrollView.addSubview(contentView)

        let blockStack = buildSubStack("BLOCK", value: viewModel.info.blockHash)
        mainStack.addArrangedSubview(blockStack)

        typeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.topMargin).offset(AppStyle.Size.padding)
            make.height.equalTo(25.0)
            make.leading.equalToSuperview().offset(AppStyle.Size.padding)
            make.trailing.equalToSuperview().offset(-AppStyle.Size.padding)
        }
        dateLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(typeLabel.snp.centerY)
            make.trailing.equalToSuperview().offset(-AppStyle.Size.padding)
        }
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(typeLabel.snp.bottom).offset(AppStyle.Size.padding)
            make.bottom.leading.trailing.equalToSuperview()
        }
        contentView.snp.makeConstraints { (make) in
            make.width.top.bottom.leading.trailing.equalToSuperview()

        }
        mainStack.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(AppStyle.Size.padding)
            make.trailing.equalToSuperview().offset(-AppStyle.Size.padding)
        }
    }
    
    fileprivate func buildStackView() {
        guard let contents = viewModel.model?.contentsObject else { return }
        
        // Source
        if viewModel.info.type == "receive" {
            let sourceStack = buildSubStack("SOURCE", value: viewModel.model?.sourceAccount)
            mainStack.addArrangedSubview(sourceStack)
        }
        
        // Amount
        let amountStack = buildSubStack("AMOUNT", value: viewModel.info.amount.decimalNumber.mxrbString.formattedAmount + " NANO")
        mainStack.addArrangedSubview(amountStack)
        
        dateLabel.text = viewModel.localizedDate
        contents.sorted { $0.key < $1.key }.forEach {
            let value = $0.key == "balance" ? $0.value.decimalNumber.mxrbString.formattedAmount + " NANO" : $0.value
            mainStack.addArrangedSubview(buildSubStack($0.key, value: value))
        }
    }
    
    override func setupNavBar() {
        super.setupNavBar()
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "back2"), style: .plain, target: self, action: #selector(backTapped))
        backButton.tintColor = .white
        navigationItem.leftBarButtonItem = backButton
        
        let externalButton = UIBarButtonItem(image: #imageLiteral(resourceName: "external"), style: .plain, target: self, action: #selector(externalTapped))
        externalButton.tintColor = .white
        navigationItem.rightBarButtonItem = externalButton
    }
    
    // MARK: - Actions
    
    @objc func externalTapped() {
        guard let url = URL(string: BLOCK_EXPLORER_URL + viewModel.info.blockHash) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @objc func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Helpers
    
    fileprivate func buildSubStack(_ title: String, value: String?) -> UIStackView {
        let value = value ?? "---"
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4.0
        stack.distribution = .fill
        let titleLabel = buildStackLabel(title, isTitle: true)
        let valueLabel = buildStackLabel(value, isTitle: false)
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(valueLabel)
        return stack
    }
    
    fileprivate func buildStackLabel(_ value: String, isTitle: Bool) -> UILabel {
        let label = UILabel()
        label.font = isTitle ? .systemFont(ofSize: 14) : .systemFont(ofSize: 14, weight: .light)
        label.textColor = isTitle ? .white : AppStyle.Color.lowAlphaWhite
        label.text = isTitle ? value.uppercased() : value
        label.numberOfLines = 0
        label.alpha = 0
        UIView.animate(withDuration: 0.3) {
            label.alpha = 1.0
        }
        return label
    }
}
