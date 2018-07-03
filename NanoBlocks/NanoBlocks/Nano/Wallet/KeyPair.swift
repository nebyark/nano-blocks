//
//  KeyPair.swift
//  NanoBlocks
//
//  Created by Ben Kray on 5/9/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import Foundation

struct KeyPair {
    var publicKey: Data
    var secretKey: Data
}

extension KeyPair {
    var xrbAccount: String? {
        return try? WalletUtil.deriveXRBAccount(from: publicKey)
    }
}
