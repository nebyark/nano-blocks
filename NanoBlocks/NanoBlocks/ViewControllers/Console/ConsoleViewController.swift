//
//  ConsoleViewController.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 2/13/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import UIKit

class ConsoleViewController: TransparentNavViewController {
    
    @IBOutlet weak var consoleTextView: UITextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupView()
    }
    
    // MARK: - Setup
    
    fileprivate func setupView() {
        consoleTextView?.isEditable = false
        consoleTextView?.text = Lincoln.consoleLog.joined(separator: "\n------------------------\n")
    }
    
    override func setupNavBar() {
        super.setupNavBar()
        let share = UIBarButtonItem(title: .localize("export"), style: .done, target: self, action: #selector(shareConsole))
        share.tintColor = .black
        let clear = UIBarButtonItem.init(title: .localize("clear"), style: .plain, target: self, action: #selector(clearConsole))
        clear.tintColor = .red
        navigationItem.rightBarButtonItems = [clear, share]
    }
    
    // MARK: - Actions
    
    @objc fileprivate func shareConsole() {
        var items: [Any] = []
        items.append(consoleTextView?.text ?? "")
        let shareVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(shareVC, animated: true)
    }
    
    @objc fileprivate func clearConsole() {
        consoleTextView?.text = ""
        Lincoln.clearLog()
    }
}
