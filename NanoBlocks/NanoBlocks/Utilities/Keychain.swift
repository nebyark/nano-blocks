//
//  Keychain.swift
//
//  Created by Ben Kray on 7/7/17.
//  Copyright © 2017 Planar Form. All rights reserved.
//

import Foundation
import Security

struct KeychainConfig {
    let accessGroup: String?
    let userAccount: String?
    let service: String
}

enum AccessibilityOptions {
    case whenUnlocked
    case afterFirstUnlock
    case always
    case whenPasscodeSetThisDeviceOnly
    case whenUnlockedThisDeviceOnly
    case afterFirstUnlockThisDeviceOnly
    case alwaysThisDeviceOnly
    
    var value: String {
        switch self {
        case .whenUnlocked:
            return kSecAttrAccessibleWhenUnlocked as String
        case .afterFirstUnlock:
            return kSecAttrAccessibleAfterFirstUnlock as String
        case .always:
            return kSecAttrAccessibleAlways as String
        case .whenPasscodeSetThisDeviceOnly:
            return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly as String
        case .whenUnlockedThisDeviceOnly:
            return kSecAttrAccessibleWhenUnlockedThisDeviceOnly as String
        case .afterFirstUnlockThisDeviceOnly:
            return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly as String
        case .alwaysThisDeviceOnly:
            return kSecAttrAccessibleAlwaysThisDeviceOnly as String
        }
    }
}

class Keychain {
    private var config: KeychainConfig
    static let standard: Keychain = {
        let s = Bundle.main.bundleIdentifier ?? "my-little-keychain"
        let c = KeychainConfig(accessGroup: nil, userAccount: "standard", service: s)
        return Keychain(configuration: c)
    }()
    
    init(configuration: KeychainConfig) {
        self.config = configuration
    }
    
    @discardableResult
    func set(value: Data, key: String, accessibility: AccessibilityOptions? = nil) -> Bool {
        _ = remove(key: key)
        let option: String = accessibility?.value ?? AccessibilityOptions.whenUnlockedThisDeviceOnly.value
        let query = createQuery(key: key, options: [.valueData: value, .accessible: option])
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        return status == errSecSuccess
    }
    
    @discardableResult
    func remove(key: String) -> Bool {
        let query = createQuery(key: key)
        
        let status = SecItemDelete(query as CFDictionary)
        
        return status == errSecSuccess
    }
    
    func contains(key: String) -> Bool {
        let query = createQuery(key: key, options: [.returnData: kCFBooleanTrue, .matchLimit: kSecMatchLimitOne])
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        return status == errSecItemNotFound
    }
    
    func get(key: String) -> Data? {
        let query = createQuery(key: key, options: [.returnData: kCFBooleanTrue, .matchLimit: kSecMatchLimitOne])

        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        guard status != errSecItemNotFound, let queryData: Data = queryResult as? Data else {
            return nil
        }
        
        return queryData
    }
    
    fileprivate func createQuery(key: String, options: [String: Any]? = nil) -> [String: Any] {
        let prefixedKey = config.userAccount != nil ? config.userAccount! + key : key
        var query: [String: Any] = [
            .itemClass: kSecClassGenericPassword,
            .attrService: config.service,
            .attrAccount: prefixedKey
        ]
        if let accessGroup = config.accessGroup {
            query[.attrAccessGroup] = accessGroup as Any
        }
        if let options = options {
            options.forEach { (k, v) in
                query[k] = v
            }
        }
        
        return query
    }
}

// MARK: - Keychain Constants

extension String {
    static var itemClass: String { return kSecClass as String }
    static var attrAccount: String { return kSecAttrAccount as String }
    static var valueData: String { return kSecValueData as String }
    static var attrService: String { return kSecAttrService as String }
    static var matchLimit: String { return kSecMatchLimit as String }
    static var returnData: String { return kSecReturnData as String }
    static var matchLimitOne: String { return kSecMatchLimitOne as String }
    static var accessible: String { return kSecAttrAccessible as String }
    static var attrAccessGroup: String { return kSecAttrAccessGroup as String }
}
