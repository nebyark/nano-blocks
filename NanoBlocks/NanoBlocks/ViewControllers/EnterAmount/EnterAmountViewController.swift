//
//  EnterAmountViewController.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 1/28/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import UIKit

class EnterAmountViewController: UIViewController {

    fileprivate let feedback = UINotificationFeedbackGenerator()
    fileprivate let impact = UIImpactFeedbackGenerator(style: .medium)
    @IBOutlet weak var continueButton: UIButton?
    @IBOutlet weak var currencyButton: UIButton?
    @IBOutlet weak var amountLabel: UILabel?
    @IBOutlet weak var collectionView: UICollectionView?
    @IBOutlet weak var balanceLabel: UILabel?
    fileprivate var amount: NSDecimalNumber = 0.0
    fileprivate var isShowingSecondary: Bool = false
    fileprivate let rows: CGFloat = 4
    fileprivate let cols: CGFloat = 3
    let account: AccountInfo
    var enteredAmount: ((String) -> Void)?

    init(with account: AccountInfo) {
        self.account = account
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        feedback.prepare()
        impact.prepare()
        setupNavBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupView()
        setupKeyboard()
    }
    
    // MARK: - Setup
    
    fileprivate func setupView() {
        guard let continueButton = continueButton else { return }
        let gradient = AppStyle.buttonGradient
        gradient.frame = continueButton.bounds
        continueButton.layer.insertSublayer(gradient, below: continueButton.imageView!.layer)
        continueButton.setImage(#imageLiteral(resourceName: "xrb_check").withRenderingMode(.alwaysTemplate), for: .normal)
        continueButton.tintColor = .white
        balanceLabel?.text = String.localize("available-balance-arg", arg: account.formattedBalance).uppercased()
        balanceLabel?.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(balanceTapped))
        balanceLabel?.addGestureRecognizer(gesture)
        currencyButton?.layer.borderColor = AppStyle.lightGrey.cgColor
        currencyButton?.layer.borderWidth = 1.0
        currencyButton?.layer.cornerRadius = 20.0
    }
    
    fileprivate func setupNavBar() {
        let leftBarItem = UIBarButtonItem(image: #imageLiteral(resourceName: "close2").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(closeTapped))
        leftBarItem.tintColor = .white
        navigationItem.leftBarButtonItem = leftBarItem

        title = .localize("enter-amount-title")
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
    }
    
    fileprivate func setupKeyboard() {
        let bg = UIImageView(image: #imageLiteral(resourceName: "xrb_bg_2b3165"))
        bg.frame = view.frame
        collectionView?.superview?.clipsToBounds = true
        collectionView?.superview?.insertSubview(bg, at: 0)
        collectionView?.delegate = self
        collectionView?.dataSource = self
        let nib = UINib(nibName: NumpadCollectionViewCell.identifier, bundle: nil)
        collectionView?.register(nib, forCellWithReuseIdentifier: NumpadCollectionViewCell.identifier)
        collectionView?.backgroundColor = .clear
        collectionView?.isScrollEnabled = false
        guard let collectionView = collectionView else { return }
        let cellSize = CGSize(width: collectionView.bounds.width / cols - 1, height: collectionView.bounds.height / rows)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = cellSize
        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        layout.minimumLineSpacing = 1.0
        layout.minimumInteritemSpacing = 1.0
        collectionView.collectionViewLayout = layout
    }
    
    // MARK: - Actions
    
    @objc fileprivate func balanceTapped() {
        amountLabel?.text = account.formattedBalance
        amount = account.mxrbBalance.decimalNumber
    }
    
    @objc fileprivate func closeTapped() {
        dismiss(animated: true)
    }
    
    @IBAction func currencyButtonTapped(_ sender: Any) {
        isShowingSecondary = !isShowingSecondary
        if isShowingSecondary {
            let secondary = Currency.secondary
            let converted = secondary.convert(self.amount, isRaw: false)
            balanceLabel?.text = String.localize("available-balance-arg", arg: converted).uppercased()
            currencyButton?.setTitle(secondary.rawValue.uppercased(), for: .normal)
            amountLabel?.text = converted
        } else {
            currencyButton?.setTitle("NANO", for: .normal)
            let amountText = amount.stringValue
            amountLabel?.text = amountText
            balanceLabel?.text = String.localize("available-balance-arg", arg: account.formattedBalance).uppercased()
        }
    }
    
    @IBAction func continueTapped(_ sender: Any) {
        guard amount.decimalValue > 0.0 else {
            feedback.notificationOccurred(.error)
            return
        }
        if amount.decimalValue > account.mxrbBalance.decimalNumber.decimalValue {
            Banner.show(.localize("insufficient-funds"), style: .danger)
            return
        }
        dismiss(animated: true)
        // Return value in Nano
        enteredAmount?(amount.stringValue)
    }
}

extension EnterAmountViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}

extension EnterAmountViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        // lol this can be cleaned up
        guard let amountText = amountLabel?.text else { return }
        if indexPath.item == 11, let count = amountLabel?.text?.count, count > 0 {
            amountLabel?.text = String(amountLabel?.text?.prefix(count - 1) ?? "0")
        }
        let components = amountText.split(separator: ".")
        if components.count > 1 {
            guard components[1].count < 6 else {
                feedback.notificationOccurred(.error)
                return
            }
        }
        if indexPath.item < 9 {
            if Double(amountText) == 0, !amountText.contains(".") {
                amountLabel?.text = ""
            }
            let temp: String = "\(amountLabel?.text ?? "")\(indexPath.item + 1)"
            if let _ = Double(temp) {
                amountLabel?.text = temp
                impact.impactOccurred()
            } else {
                feedback.notificationOccurred(.error)
            }
        } else if indexPath.item == 9 {
            let temp = "\(amountText)."
            if let _ = Double(temp) {
                amountLabel?.text = temp
                impact.impactOccurred()
            } else {
                feedback.notificationOccurred(.error)
            }
        } else if indexPath.item == 10 {
            let temp = "\(amountText)0"
            if let _ = Double(temp), amountLabel?.text != "0" {
                amountLabel?.text = temp
                impact.impactOccurred()
            } else {
                feedback.notificationOccurred(.error)
            }
        }
        if amountLabel?.text == "" {
            amountLabel?.text = "0"
        }

        let value = NSDecimalNumber(string: amountLabel?.text)
        amount = isShowingSecondary ? value.dividing(by: NSDecimalNumber(decimal: Decimal(Currency.secondaryConversionRate))) : value
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension EnterAmountViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NumpadCollectionViewCell.identifier, for: indexPath) as? NumpadCollectionViewCell else { return UICollectionViewCell() }
        if indexPath.item < 9 {
            cell.valueLabel?.text = "\(indexPath.item + 1)"
        } else if indexPath.item == 9 {
            cell.valueLabel?.text = "."
        } else if indexPath.item == 10 {
            cell.valueLabel?.text = "0"
        } else if indexPath.item == 11 {
            cell.valueImageView?.image = #imageLiteral(resourceName: "backspace").withRenderingMode(.alwaysTemplate)
            cell.valueImageView?.tintColor = .white
        }
        cell.valueLabel?.textColor = .white
        return cell
    }
}
