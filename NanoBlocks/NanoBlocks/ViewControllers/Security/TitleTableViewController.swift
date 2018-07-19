//
//  TitleTableViewController.swift
//  NanoBlocks
//
//  Created by Ben Kray on 4/22/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import UIKit
import SnapKit

class TitleTableViewController: TransparentNavViewController {

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableViewAutomaticDimension
        return tableView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = self.titleText
        label.font = AppStyle.Font.title
        return label
    }()
    
    var titleText: String? {
        didSet {
            self.titleLabel.text = self.titleText
        }
    }
    
    init(title: String) {
        self.titleText = title
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - Setup
    
    func setupView() {
        view.backgroundColor = .white
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.topMargin).offset(AppStyle.Size.smallPadding)
            } else {
                make.top.equalToSuperview().offset(AppStyle.Size.padding)
            }
            make.left.equalTo(view.snp.left).offset(AppStyle.Size.padding)
            make.right.equalTo(view.snp.right)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.bottom.equalTo(view.snp.bottom)
        }
    }
}
