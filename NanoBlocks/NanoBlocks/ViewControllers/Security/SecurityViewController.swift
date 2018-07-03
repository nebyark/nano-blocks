//
//  SecurityViewController.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 2/13/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import UIKit
import LocalAuthentication

class SecurityViewController: TitleTableViewController {
    enum Row: Int, CaseCountable {
        case biometricsOnSend
        case biometricsOnLaunch
        case changePassword
        case showSeed
        
        static var caseCount: Int = Row.countCases()
    }
    
    var onChangePasswordTapped: (() -> Void)?
    var onShowSeedTapped: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    // MARK: - Setup
    
    fileprivate func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SettingsTableViewCell.self)
        tableView.register(SwitchTableViewCell.self)
    }
    
    // MARK: - Actions
    
    @objc fileprivate func onSwitch(_ sender: UISwitch) {
        guard let row = Row(rawValue: sender.tag) else { return }
        if row == .biometricsOnSend {
            UserSettings.biometricsOnSend(set: sender.isOn)
        } else if row == .biometricsOnLaunch {
            let context = LAContext()
            var error: NSError? = NSError()
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let passwordVC = PasswordViewController(action: .authenticate, style: .white, hideNav: false)
                passwordVC.onDismiss = {
                    sender.setOn(!sender.isOn, animated: true)
                }
                passwordVC.onAuthenticated = { (pw) in
                    self.handleBiometricsSetup(pw)
                }
                navigationController?.pushViewController(passwordVC, animated: true)
            }  else {
                if let msg = error?.localizedDescription {
                    Banner.show(msg, style: .danger)
                }
                sender.setOn(false, animated: true)
            }
        }
    }
    
    func handleBiometricsSetup(_ pw: String) {
        if UserSettings.requireBiometricseOnLaunch {
            UserSettings.biometricsOnLaunch(set: false)
            Keychain.standard.remove(key: KeychainKey.biometricsKey)
        } else {
            guard let passwordData = pw.data(using: .utf8), let salt = Keychain.standard.get(key: KeychainKey.salt) else { return }
            guard let key = NaCl.hash(passwordData, salt: salt) else { return }
            Keychain.standard.set(value: key, key: KeychainKey.biometricsKey)
            UserSettings.biometricsOnLaunch(set: true)
        }
        navigationController?.popViewController(animated: true)

    }
}

extension SecurityViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let row = Row(rawValue: indexPath.row) else { return }
        if row == .changePassword {
            onChangePasswordTapped?()
        } else if row == .showSeed {
            onShowSeedTapped?()
        }
    }
}

extension SecurityViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let row = Row(rawValue: indexPath.row) else { return UITableViewCell() }
        switch row {
        case .biometricsOnSend, .biometricsOnLaunch:
            let cell = tableView.dequeueReusableCell(SwitchTableViewCell.self, for: indexPath)
            cell.titleLabel?.text = row == .biometricsOnSend ? .localize("require-biometrics-send") : .localize("require-biometrics-launch")
            cell.animatedSwitch?.setOn(row == .biometricsOnSend ? UserSettings.requireBiometricsOnSend : UserSettings.requireBiometricseOnLaunch, animated: true)
            cell.animatedSwitch?.tag = row.rawValue
            cell.animatedSwitch?.addTarget(self, action: #selector(onSwitch(_:)), for: .valueChanged)
            cell.selectionStyle = .none
            return cell
        case .changePassword, .showSeed:
            let cell = tableView.dequeueReusableCell(SettingsTableViewCell.self, for: indexPath)
            cell.settingsTitleLabel?.text = row == .changePassword ? .localize("change-password") : .localize("show-seed")
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Row.caseCount
    }
}
