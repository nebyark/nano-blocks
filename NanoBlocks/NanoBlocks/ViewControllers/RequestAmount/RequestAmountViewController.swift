//
//  RequestAmountViewController.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 2/22/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import UIKit

class RequestAmountViewController: UIViewController {

    fileprivate let feedback = UINotificationFeedbackGenerator()
    fileprivate let impact = UIImpactFeedbackGenerator(style: .medium)
    @IBOutlet weak var currencyButton: UIButton?
    @IBOutlet weak var shareButton: UIButton?
    @IBOutlet weak var qrImageView: UIImageView?
    @IBOutlet weak var collectionView: UICollectionView?
    @IBOutlet weak var amountLabel: UILabel?
    fileprivate var isShowingSecondary: Bool = false
    fileprivate let rows: CGFloat = 4
    fileprivate let cols: CGFloat = 3
    let account: AccountInfo
    
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
        setupView()
        setupNavBar()
        updateQRCode()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupKeyboard()
    }
    
    // MARK: - Setup
    
    fileprivate func setupView() {
        currencyButton?.layer.borderColor = AppStyle.lightGrey.cgColor
        currencyButton?.layer.borderWidth = 1.0
        currencyButton?.layer.cornerRadius = 20.0
        shareButton?.setTitle(.localize("share"), for: .normal)
    }
    
    fileprivate func setupNavBar() {
        let leftBarItem = UIBarButtonItem(image: #imageLiteral(resourceName: "close2").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(closeTapped))
        leftBarItem.tintColor = .white
        navigationItem.leftBarButtonItem = leftBarItem
        title = .localize("request-amount")
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
    }
    
    fileprivate func setupKeyboard() {
        guard let shareButton = shareButton else { return }
        let gradient = AppStyle.buttonGradient
        gradient.frame = shareButton.bounds
        shareButton.layer.insertSublayer(gradient, below: shareButton.imageView!.layer)
        shareButton.tintColor = .white
        
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
    
    @IBAction func currencyButtonTapped(_ sender: Any) {
        guard let value = Double(amountLabel?.text ?? "0") else { return }
        isShowingSecondary = !isShowingSecondary
        if isShowingSecondary {
            let rate = value * Currency.secondaryConversionRate
            let secondary = Currency.secondary
            currencyButton?.setTitle(secondary.rawValue.uppercased(), for: .normal)
            amountLabel?.text = rate.chopDecimal(to: secondary.precision).trimTrailingZeros()
        } else {
            let rate = value / Currency.secondaryConversionRate
            currencyButton?.setTitle("NANO", for: .normal)
            amountLabel?.text = rate.chopDecimal(to: 6).trimTrailingZeros()
        }
    }
    
    @objc fileprivate func closeTapped() {
        dismiss(animated: true)
    }
    
    @IBAction func shareTapped(_ sender: Any) {
        guard let address = account.address, let amount = amountLabel?.text, var value = Double(amount) else { return }
        if isShowingSecondary {
            value = value / Currency.secondaryConversionRate
        }
        var items: [Any] = []
        let shareText: String = "Amount to send: \(value.chopDecimal(to: 6)) NANO\nAddress: \(address)"
        if let image = qrImageView?.image?.maskWithColor(.black) {
            items.append(image)
        }
        items.append(shareText)
        let shareVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(shareVC, animated: true)
    }
    
    fileprivate func updateQRCode() {
        guard let amount = amountLabel?.text,
            let address = account.address,
            let rawAmount = Double(amount)?.toRaw else { return}
        let xrbStandard = "xrb:\(address)?amount=\(rawAmount)"
        guard let requestData = xrbStandard.data(using: .utf8), let qrImageView = qrImageView else { return }
        qrImageView.image = UIImage
            .qrCode(data: requestData, color: .white)?
            .resize(CGSize(width: qrImageView.bounds.width, height: qrImageView.bounds.height))
    }
}

extension RequestAmountViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}

extension RequestAmountViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let amountText = amountLabel?.text else { return }
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
            if let _ = Double(temp), amountText != "0" {
                amountLabel?.text = temp
                impact.impactOccurred()
            } else {
                feedback.notificationOccurred(.error)
            }
        } else if indexPath.item == 11, let count = amountLabel?.text?.count, count > 0 {
            amountLabel?.text = String(amountLabel?.text?.prefix(count - 1) ?? "0")
        }
        if amountLabel?.text == "" {
            amountLabel?.text = "0"
        }
        
        updateQRCode()
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension RequestAmountViewController: UICollectionViewDataSource {
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
