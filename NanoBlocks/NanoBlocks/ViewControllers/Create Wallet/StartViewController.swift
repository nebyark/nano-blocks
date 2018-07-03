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

    @IBOutlet weak var welcome2Label: UILabel?
    @IBOutlet weak var welcome1Label: UILabel?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var logoImageView: UIImageView?
    @IBOutlet weak var newWalletButton: UIButton?
    @IBOutlet weak var importWalletButton: UIButton?
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
        logoImageView?.image = #imageLiteral(resourceName: "welcome_xrb").withRenderingMode(.alwaysTemplate)
        logoImageView?.tintColor = .white
        importWalletButton?.semanticContentAttribute = .forceLeftToRight
        importWalletButton?.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        importWalletButton?.layer.borderWidth = 1.0
        newWalletButton?.setImage(#imageLiteral(resourceName: "nav_plus").withRenderingMode(.alwaysTemplate), for: .normal)
        importWalletButton?.setImage(#imageLiteral(resourceName: "welcome_import").withRenderingMode(.alwaysTemplate) , for: .normal)
        importWalletButton?.imageView?.tintColor = .white
        
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
        
        titleLabel?.text = .localize("nano-blocks")
        welcome1Label?.text = .localize("welcome-1")
        welcome2Label?.text = .localize("welcome-2")
        newWalletButton?.setTitle(.localize("new-wallet"), for: .normal)
        importWalletButton?.setTitle(.localize("import-wallet"), for: .normal)
    }
    
    // MARK: - Actions
    
    @IBAction func newWalletTapped(_ sender: Any) {
        delegate?.newWalletTapped()
    }
    
    @IBAction func importWalletTapped(_ sender: Any) {
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
