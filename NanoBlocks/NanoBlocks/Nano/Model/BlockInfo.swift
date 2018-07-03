//
//  BlockInfo.swift
// NanoBlocks
//
//  Created by Ben Kray on 4/19/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import Foundation

struct BlockInfo {
    
    let blockAccount: String?
    let sourceAccount: String?
    let amount: String?
    let contents: String?
    let timestamp: Int?
    var contentsObject: [String: String]? {
        guard let jsonData = contents?.data(using: .utf8) else { return nil }
        guard let obj = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: String] else { return nil }
        return obj
    }
    
    init(_ json: [String: Any]?) {
        self.blockAccount = json?["block_account"] as? String
        self.amount = json?["amount"] as? String
        self.contents = json?["contents"] as? String
        self.timestamp = json?["timestamp"] as? Int
        self.sourceAccount = json?["source_account"] as? String
    }
}
