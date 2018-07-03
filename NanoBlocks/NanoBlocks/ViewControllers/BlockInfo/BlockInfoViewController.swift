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
    let mainStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12.0
        stackView.distribution = .fill
        return stackView
    }()
    let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17.0, weight: .light)
        label.textColor = AppStyle.Color.lowAlphaWhite
        return label
    }()
    
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
    
    // MARK: - Setup
    
    fileprivate func buildView() {
        let typeLabel = UILabel()
        typeLabel.font = .systemFont(ofSize: 25.0, weight: .medium)
        typeLabel.textColor = .white
        typeLabel.text = viewModel.info.type.capitalized(with: .current)
        view.addSubview(typeLabel)
        view.addSubview(dateLabel)
        
        let scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.addSubview(mainStack)
        
        let blockStack = buildSubStack("BLOCK", value: viewModel.info.blockHash)
        mainStack.addArrangedSubview(blockStack)
  
        typeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.topMargin).offset(AppStyle.Size.padding)
            make.height.equalTo(25.0)
            make.left.equalTo(AppStyle.Size.padding)
            make.right.equalTo(-AppStyle.Size.padding)
        }
        dateLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(typeLabel.snp.centerY)
            make.right.equalTo(-AppStyle.Size.padding)
        }
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(typeLabel.snp.bottom).offset(AppStyle.Size.padding)
            make.left.equalTo(AppStyle.Size.padding)
            make.right.equalTo(-AppStyle.Size.padding)
            make.bottom.equalTo(view.snp.bottomMargin).offset(AppStyle.Size.padding)
        }
        mainStack.snp.makeConstraints { (make) in
            make.top.equalTo(scrollView.snp.top)
            make.bottom.equalTo(scrollView.snp.bottom)
            make.right.equalTo(scrollView.snp.right)
            make.width.equalTo(scrollView.snp.width)
            make.left.equalTo(scrollView.snp.left)
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
        let amountStack = buildSubStack("AMOUNT", value: viewModel.info.amount.bNumber.toMxrb.trimTrailingZeros() + " NANO")
        mainStack.addArrangedSubview(amountStack)
        
        dateLabel.text = viewModel.localizedDate
        contents.sorted { $0.key < $1.key }.forEach {
            let value = $0.key == "balance" ? $0.value.bNumber.toMxrb + " NANO" : $0.value
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