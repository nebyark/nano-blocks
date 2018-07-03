//
//  AboutViewController.swift
// NanoBlocks
//
//  Created by Ben Kray on 3/10/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import UIKit

class AboutViewController: TitleTableViewController {
    enum Rows: Int, CaseCountable {
        static var caseCount: Int = Rows.countCases()
        case disclaimer, discord, twitter, blog, donate
    }
    
    lazy var versionLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppStyle.Color.offBlack
        label.font = .systemFont(ofSize: 12.0, weight: .light)
        if let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
            let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
            label.text = "Nano Blocks - v\(versionNumber) (\(buildNumber))"
        }
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        view.addSubview(self.versionLabel)
        self.versionLabel.snp.makeConstraints { (make) in
            make.bottomMargin.equalToSuperview().offset(-AppStyle.Size.padding)
            make.leading.equalToSuperview().offset(AppStyle.Size.padding)
        }
    }
    
    // MARK: - Setup
    
    fileprivate func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SettingsTableViewCell.self)
    }
}

extension AboutViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let row = Rows(rawValue: indexPath.row) else { return }
        var urlString = ""
        switch row {
        case .disclaimer:
            navigationController?.pushViewController(DisclaimerViewController(showButtons: false), animated: true)
        case .blog:
            urlString = "https://medium.com/@benkray"
        case .discord:
            urlString = "https://discord.gg/n76DkEt"
        case .donate:
            UIPasteboard.general.string = "xrb_36sqki6ggsrqwy4ryw19c45dx6fa4unb49ukozyz1zs6s9o1mpoq58yotuc8"
            Banner.show(.localize("dev-address-copied"), style: .success)
            return
        case .twitter:
            urlString = "https://twitter.com/nebyark"
        }
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

extension AboutViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Rows.caseCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let row = Rows(rawValue: indexPath.row) else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(SettingsTableViewCell.self, for: indexPath)
        switch row {
        case .disclaimer:
            cell.settingsTitleLabel?.text = "Disclaimer"
        case .blog:
            cell.settingsTitleLabel?.text = .localize("blog")
        case .discord:
            cell.settingsTitleLabel?.text = "Discord"
        case .donate:
            cell.settingsTitleLabel?.text = .localize("dev-donation-address")
            cell.rightImageView?.image = #imageLiteral(resourceName: "clipboard")
        case .twitter:
            cell.settingsTitleLabel?.text = .localize("twitter")
        }
        
        return cell
    }
}
