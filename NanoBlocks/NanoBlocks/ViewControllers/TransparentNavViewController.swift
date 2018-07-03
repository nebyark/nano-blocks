//
//  TransparentNavViewController.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 2/13/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import UIKit

class TransparentNavViewController: UIViewController {

    var continueButton: UIButton?
    var keyboardHeight: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
        setupNavBar()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func setupContinueButton(_ color: UIColor = .white) {
        let x = view.bounds.width - 80
        let y = view.bounds.height - 80
        continueButton = UIButton(frame: .zero)
        continueButton?.setBackgroundImage(#imageLiteral(resourceName: "continue").withRenderingMode(.alwaysTemplate), for: .normal)
        continueButton?.tintColor = color
        continueButton?.frame = CGRect(x: x, y: y, width: 52, height: 52)
        continueButton?.isHidden = true
    }
    
    func setupNavBar() {
        let image = #imageLiteral(resourceName: "back2").withRenderingMode(.alwaysOriginal)
        navigationController?.navigationBar.backIndicatorImage = image
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = image
        navigationController?.navigationBar.topItem?.title = ""
    }
    
    // MARK: - Actions
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        var keyboardHeight: CGFloat = 80
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
        }
        let x = view.bounds.width - 80
        let y = view.bounds.height - keyboardHeight - 80
        guard let continueButton = continueButton else { return }
        UIView.animate(withDuration: 0.3) {
            continueButton.frame = CGRect(x: x, y: y, width: continueButton.bounds.width, height: continueButton.bounds.height)
        }
    }
    
    @objc func keyboardWillHide() {
        let x = view.bounds.width - 80
        let y = view.bounds.height - 80
        guard let continueButton = continueButton else { return }
        UIView.animate(withDuration: 0.3) {
            continueButton.frame = CGRect(x: x, y: y, width: continueButton.bounds.width, height: continueButton.bounds.height)
        }
    }
}

extension TransparentNavViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let continueButton = continueButton else { return false }
        return !(touch.view?.isDescendant(of: continueButton) ?? true)
    }
}
