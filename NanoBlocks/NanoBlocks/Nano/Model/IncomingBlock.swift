//
//  IncomingBlock.swift
// NanoBlocks
//
//  Created by Ben Kray on 4/1/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import Foundation

struct BlockMeta: Codable {
    var type: String
    var previous: String
    var link: String
    var link_as_account: String
    var representative: String
    var account: String
    var balance: String
    var work: String
    var signature: String
}

struct IncomingBlock: Codable {
    var account: String
    var hash: String
    var timestamp: Int
    var amount: String
    var block: String
    
    func meta() -> BlockMeta? {
        guard let data = block.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(BlockMeta.self, from: data)
    }
}
