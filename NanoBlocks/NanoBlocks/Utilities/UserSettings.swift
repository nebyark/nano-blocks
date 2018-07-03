//
//  UserSettings.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 2/13/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import Foundation

struct UserSettings {
    static var requireBiometricsOnSend: Bool {
        return Keychain.standard.get(key: KeychainKey.useBiometricsOnSend) != nil
    }
    
    static var requireBiometricseOnLaunch: Bool {
        return Keychain.standard.get(key: KeychainKey.useBiometricsOnLaunch) != nil
    }
    
    static func biometricsOnSend(set value: Bool) {
        if value {
            Keychain.standard.set(value: Data(), key: KeychainKey.useBiometricsOnSend)
        } else {
            Keychain.standard.remove(key: KeychainKey.useBiometricsOnSend)
        }
    }
    
    static func biometricsOnLaunch(set value: Bool) {
        if value {
            Keychain.standard.set(value: Data(), key: KeychainKey.useBiometricsOnLaunch)
        } else {
            Keychain.standard.remove(key: KeychainKey.useBiometricsOnLaunch)
        }
    }
}
