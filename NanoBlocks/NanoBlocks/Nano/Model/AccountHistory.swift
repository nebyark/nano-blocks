//
// AccountHistory.swift
//
// Created by JSON Bourne on 01/13/2018.
// Copyright © 2018 . All rights reserved.

import Foundation

struct AccountBalance {
    var pending: Double
    var balance: Double
    
    init(json: [String: Any]?) {
        pending = Double(json?["pending"] as? String ?? "0.0") ?? 0.0
        balance = Double(json?["balance"] as? String ?? "0.0") ?? 0.0
    }
}

struct AccountHistory {
    
    // MARK: - Properties
    
    var hash: String?
    var type: Block.BlockType?
    var account: String?
    var amount: String?
    
    // MARK: - Initializers
    
    public init(json: [String: Any]) {
        hash = json["hash"] as? String
        if let raw = json["type"] as? String {
            type = Block.BlockType(rawValue: raw)
        }
        account = json["account"] as? String
        amount = json["amount"] as? String
    }
    
    // MARK: - Methods
    
    public func toDictionary() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let value = hash { dictionary["hash"] = value }
        if let value = type { dictionary["type"] = value }
        if let value = account { dictionary["account"] = value }
        if let value = amount { dictionary["amount"] = value }
        return dictionary
    }
}

