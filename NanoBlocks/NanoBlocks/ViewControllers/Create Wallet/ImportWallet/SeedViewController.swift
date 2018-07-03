//
//  ImportSeedViewController.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 1/7/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import UIKit
import SSZipArchive

protocol SeedViewControllerDelegate: class {
    func imported(seed: Data)
}

class SeedViewController: TransparentNavViewController {
    enum Action {
        case showSeed
        case importSeed
    }
    enum Style {
        case white
        case blue
    }
    @IBOutlet weak var subtitleLabel: UILabel?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var textView: UITextView?
    fileprivate var action: Action
    fileprivate var style: Style
    fileprivate var seed: Data?
    fileprivate var dataExporter: DataExporter?
    
    weak var delegate: SeedViewControllerDelegate?
    
    init(action: Action, style: Style, seed: Data? = nil) {
        self.action = action
        self.seed = seed
        self.style = style
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            // safe area by default
        } else {
            // XIB file hack for backwards compatibilty
            titleLabel?.topAnchor.constraint(equalTo: view.topAnchor, constant: 60).isActive = true
        }
        if let seed = seed {
            textView?.text = seed.hexString.uppercased()
        }
        if action == .importSeed {
            textView?.becomeFirstResponder()
        } else {
            textView?.isEditable = false
        }
        if style == .white {
            [titleLabel, subtitleLabel].forEach { $0?.textColor = .black }
            textView?.textColor = .black
            view.backgroundColor = .white
        }
        subtitleLabel?.text = action == .importSeed ? .localize("seed-subtitle") : .localize("seed-backup-msg")
        
        if action == .showSeed {
            let export = UIBarButtonItem(title: .localize("export"), style: .done, target: self, action: #selector(exportTapped))
            export.tintColor = style == .white ? .black : .white
            navigationItem.rightBarButtonItem = export
        }
        titleLabel?.text = .localize("seed")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if style == .blue {
            let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "back2"), style: .plain, target: self, action: #selector(backTapped))
            backButton.tintColor = style == .white ? .black : .white
            navigationItem.leftBarButtonItem = backButton
        } else {
            super.viewWillAppear(animated)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // Only add continue button when this view is used as an import seed view
        guard view.viewWithTag(420420) == nil, style == .blue else { return }
        super.setupContinueButton()
        continueButton?.tag = 420420
        continueButton?.addTarget(self, action: #selector(continuePressed), for: .touchUpInside)
        view.addSubview(continueButton!)
        continueButton?.isHidden = false
    }
    
    // MARK: - Actions
    
    @objc fileprivate func exportTapped() {
        let pwVC = PasswordViewController(action: .encrypt, style: style == .blue ? .blue : .white, hideNav: true)
        pwVC.onAuthenticated = { [weak self] (pw) in
            self?.handleZip(pw)
        }
        navigationController?.pushViewController(pwVC, animated: true)
    }
    
    @objc fileprivate func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func continuePressed(_ sender: Any) {
        guard let seed = textView?.text, seed.count == 64, let seedData = seed.hexData else {
            Lincoln.log("Seed is not 32-byte hex value")
            // TODO: Alert
            return
        }
        delegate?.imported(seed: seedData)
    }
    
    fileprivate func handleZip(_ password: String) {
        guard let seed = seed else { return }
        self.dataExporter = DataExporter(seed, password: password)

        DispatchQueue.global(qos: .background).async {
            guard let path = self.dataExporter?.export() else { return }
            DispatchQueue.main.async {
                let shareVC = UIActivityViewController(activityItems: [path], applicationActivities: [])
                shareVC.completionWithItemsHandler = { [weak self] (_, _, _, _) in
                    self?.navigationController?.popViewController(animated: true)
                }
                self.present(shareVC, animated: true)
            }
        }
    }
}
