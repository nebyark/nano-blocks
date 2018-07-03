//
//  Block.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 1/12/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import Foundation

struct Block: BlockAdapter {
    enum BlockType: String {
        case open, send, receive, change
    }
    
    var type: BlockType
    var work: String = ""
    var signature: String = ""
    var previous: String = ""
    var balance: String = ""
    var destination: String = ""
    var representative: String = ""
    var source: String = ""
    var account: String = ""
    
    // For pending
    var owner: String = ""
    var amount: String = ""

    init(type: BlockType, work: String = "", signature: String = "", previous: String = "", balance: String = "", destination: String = "", representative: String = "", source: String = "", account: String = "") {
        self.work = work
        self.signature = signature
        self.previous = previous
        self.balance = balance
        self.destination = destination
        self.representative = representative
        self.source = source
        self.account = account
        self.type = type
    }
    
    init(object: [String: Any]) {
        self.account = object["account"] as? String ?? ""
        self.balance = object["balance"] as? String ?? ""
        self.destination = object["destination"] as? String ?? ""
        self.previous = object["previous"] as? String ?? ""
        self.representative = object["representative"] as? String ?? ""
        self.signature = object["signature"] as? String ?? ""
        self.source = object["source"] as? String ?? ""
        self.owner = object["owner"] as? String ?? ""
        self.amount = object["amount"] as? String ?? ""
        self.type = Block.BlockType(rawValue: object["type"] as? String ?? "")!
    }
    
    var serializable: [String: Any] {
        var result: [String: Any] = [:]
        result[BlockKey.account] = account
        result[BlockKey.balance] = balance
        result[BlockKey.destination] = destination
        result[BlockKey.previous] = previous
        result[BlockKey.representative] = representative
        result[BlockKey.signature] = signature
        result[BlockKey.source] = source
        result[BlockKey.type] = type.rawValue
        result["owner"] = owner
        result["amount"] = amount
        
        return result
    }
    
    var json: [String: String] {
        switch type {
        case .send:
            return [
                BlockKey.type: type.rawValue,
                BlockKey.destination: destination,
                BlockKey.previous: previous,
                BlockKey.balance: balance,
                BlockKey.work: work,
                BlockKey.signature: signature
            ]
        case .receive:
            return [
                BlockKey.type: type.rawValue,
                BlockKey.source: source,
                BlockKey.previous: previous,
                BlockKey.work: work,
                BlockKey.signature: signature
            ]
        case .open:
            return [
                BlockKey.type: type.rawValue,
                BlockKey.representative: representative,
                BlockKey.account: account,
                BlockKey.source: source,
                BlockKey.work: work,
                BlockKey.signature: signature
            ]
        case .change:
            return [
                BlockKey.type: type.rawValue,
                BlockKey.representative: representative,
                BlockKey.previous: previous,
                BlockKey.work: work,
                BlockKey.signature: signature
            ]
        }
    }
}

fileprivate struct BlockKey {
    static var type: String = "type"
    static var work: String = "work"
    static var signature: String = "signature"
    static var representative: String = "representative"
    static var source: String = "source"
    static var account: String = "account"
    static var balance: String = "balance"
    static var destination: String = "destination"
    static var previous: String = "previous"
}
