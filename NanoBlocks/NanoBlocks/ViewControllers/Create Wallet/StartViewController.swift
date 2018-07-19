//
//  StartViewController.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 1/6/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import UIKit

protocol StartViewControllerDelegate: class {
    func newWalletTapped()
    func importWalletTapped()
}

class StartViewController: UIViewController {

    lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "welcome_xrb").withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .white
        return imageView
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppStyle.Font.title
        label.textColor = .white
        label.text = .localize("nano-blocks")
        return label
    }()

    lazy var welcome1Label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = AppStyle.Font.body
        label.textColor = .white
        label.text = .localize("welcome-1")
        return label
    }()

    lazy var welcome2Label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = AppStyle.Font.body
        label.textColor = .white
        label.text = .localize("welcome-2")
        return label
    }()

    lazy var newWalletButton: UIButton = {
        let button = LeftAlignedIconButton(type: .custom)
        button.setTitle(.localize("new-wallet"), for: .normal)
        button.setImage(#imageLiteral(resourceName: "nav_plus").withRenderingMode(.alwaysTemplate), for: .normal)
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 12.0, 0, 12.0)
        button.titleLabel?.font = AppStyle.Font.control
        button.setTitleColor(UIColor(rgb: 4.0, green: 154.0, blue: 255.0, alpha: 1.0), for: .normal)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(newWalletTapped(_:)), for: .touchUpInside)
        return button
    }()

    lazy var importWalletButton: UIButton = {
        let button = LeftAlignedIconButton(type: .custom)
        button.setTitle(.localize("import-wallet"), for: .normal)
        button.layer.borderColor =  UIColor.white.withAlphaComponent(0.2).cgColor
        button.layer.borderWidth = 1.0
        button.setImage(#imageLiteral(resourceName: "welcome_import").withRenderingMode(.alwaysTemplate) , for: .normal)
        button.titleLabel?.font = AppStyle.Font.control
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 12.0, 0, 12.0)
        button.tintColor = .white
        button.addTarget(self, action: #selector(importWalletTapped(_:)), for: .touchUpInside)
        return button
    }()

    fileprivate(set) var customInteractor: CustomInteractor?
    weak var delegate: StartViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = ""
        view.alpha = 0.0
        UIView.animate(withDuration: 0.5) {
            self.view.alpha = 1.0
        }
        setupView()
        navigationController?.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - Setup
    
    fileprivate func setupView() {
        view.addSubview(logoImageView)
        view.addSubview(titleLabel)
        view.addSubview(welcome1Label)
        view.addSubview(welcome2Label)
        view.addSubview(newWalletButton)
        view.addSubview(importWalletButton)

        logoImageView.snp.makeConstraints { (make) in
            make.height.width.equalTo(50.0)
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.topMargin).offset(AppStyle.Size.padding)
            } else {
                make.top.equalToSuperview().offset(AppStyle.Size.largePadding)
            }
            make.leading.equalToSuperview().offset(AppStyle.Size.padding)
        }

        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(logoImageView.snp.bottom).offset(AppStyle.Size.largePadding)
            make.leading.equalTo(logoImageView.snp.leading)
            make.trailing.equalToSuperview().offset(-AppStyle.Size.padding)
        }

        welcome1Label.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(AppStyle.Size.padding)
            make.leading.equalTo(titleLabel.snp.leading)
            make.trailing.equalTo(titleLabel.snp.trailing)
        }

        welcome2Label.snp.makeConstraints { (make) in
            make.top.equalTo(welcome1Label.snp.bottom).offset(AppStyle.Size.padding)
            make.leading.equalTo(titleLabel.snp.leading)
            make.trailing.equalTo(titleLabel.snp.trailing)
        }

        newWalletButton.snp.makeConstraints { (make) in
            make.leading.equalTo(titleLabel.snp.leading)
            make.trailing.equalTo(titleLabel.snp.trailing)
            make.height.equalTo(AppStyle.Size.control)
            make.bottom.equalTo(importWalletButton.snp.top).offset(-15.0)
        }

        importWalletButton.snp.makeConstraints { (make) in
            make.leading.equalTo(titleLabel.snp.leading)
            make.trailing.equalTo(titleLabel.snp.trailing)
            make.height.equalTo(AppStyle.Size.control)
            if #available(iOS 11.0, *) {
                make.bottomMargin.equalTo(self.view.safeAreaInsets.bottom).offset(-AppStyle.Size.mediumPadding)
            } else {
                make.bottomMargin.equalToSuperview().offset(AppStyle.Size.mediumPadding)
            }
        }

        guard let nav = navigationController else { return }
        let bgImage: UIImageView = {
            let iv = UIImageView(frame: nav.view.bounds)
            iv.image = #imageLiteral(resourceName: "xrb_bg_2b3165").withRenderingMode(.alwaysOriginal)
            iv.contentMode = .scaleAspectFill
            return iv
        }()
        view.backgroundColor = .clear
        let bgView = UIView(frame: nav.view.bounds)
        bgView.backgroundColor = AppStyle.Color.deepBlue
        nav.view.insertSubview(bgView, at: 0)
        nav.view.insertSubview(bgImage, at: 1)
    }
    
    // MARK: - Actions
    
    @objc func newWalletTapped(_ sender: Any) {
        delegate?.newWalletTapped()
    }
    
    @objc func importWalletTapped(_ sender: Any) {
        delegate?.importWalletTapped()
    }
}

extension StartViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        customInteractor = CustomInteractor(attachTo: toVC)
        return TransparentNavigationTransition(operation: operation)
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let ci = customInteractor else { return nil }
        return ci.transitionInProgress ? customInteractor : nil
    }
}
