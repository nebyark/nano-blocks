//
//  ImportPassphraseViewController.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 1/8/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import UIKit

protocol ImportPassphraseViewControllerDelegate: class {
    func imported(passphrase: [String])
}

class ImportPassphraseViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var continueButton: UIButton?
    @IBOutlet weak var collectionView: UICollectionView?
    fileprivate let rows: CGFloat = 3.0
    fileprivate let cols: CGFloat = 4.0
    fileprivate let spacing: CGFloat = 8.0
    fileprivate let totalWords: Int = 12
    weak var delegate: ImportPassphraseViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            // safe area by default
        } else {
            // XIB file hack for backwards compatibilty
            titleLabel?.topAnchor.constraint(equalTo: view.topAnchor, constant: 60).isActive = true
        }
        continueButton?.setImage(#imageLiteral(resourceName: "continue").withRenderingMode(.alwaysTemplate), for: .normal)
        continueButton?.imageView?.tintColor = .white
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - Setup
    
    fileprivate func setupCollectionView() {
        collectionView?.dataSource = self
        collectionView?.delegate = self
        let nib = UINib(nibName: PassphraseCollectionViewCell.identifier, bundle: nil)
        collectionView?.register(nib, forCellWithReuseIdentifier: PassphraseCollectionViewCell.identifier)
    }
    
    // MARK: - Actions
    
    @objc fileprivate func keyboardActionPressed(_ sender: UITextField) {
        if let cell = collectionView?.cellForItem(at: IndexPath(row: sender.tag, section: 0)) as? PassphraseCollectionViewCell {
            cell.wordTextField?.becomeFirstResponder()
        }
    }
    
    @IBAction func continueTapped(_ sender: Any) {
        // This is kinda dirty but it'll work for now (said every lazy programmer)
        var textFields: [UITextField] = []
        for i in 1...totalWords {
            if let textField = view.viewWithTag(i) as? UITextField {
                textFields.append(textField)
            }
        }
        let passphrase: [String] = textFields.compactMap { $0.text }
        guard passphrase.count == totalWords else {
            // Display alert
            Lincoln.log("Not all words provided")
            return
        }
        delegate?.imported(passphrase: passphrase)
    }
}

extension ImportPassphraseViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 24) / rows, height: (collectionView.bounds.height - 24) / cols)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
}

extension ImportPassphraseViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalWords
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PassphraseCollectionViewCell.identifier, for: indexPath) as? PassphraseCollectionViewCell else { return UICollectionViewCell() }
        let index = indexPath.item
        cell.wordTextField?.placeholder = "\(index + 1)"
        cell.wordTextField?.returnKeyType = index == totalWords - 1 ? .done : .next
        // index + 1 to account for continueTapped hack
        cell.wordTextField?.tag = index + 1
        cell.wordTextField?.addTarget(self, action: #selector(keyboardActionPressed(_:)), for: .editingDidEndOnExit)
        return cell
    }
}
