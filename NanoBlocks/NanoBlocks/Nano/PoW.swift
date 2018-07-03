//
//  PoW.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 1/13/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import Foundation

struct PoW {
    
    static func validate(_ work: String, hash: String) -> Bool {
        guard let work = work.hexData?.byteSwap(), let hash = hash.hexData else { return false }
        guard let digest = NaCl.digest([work, hash], outputLength: 8) else { return false }
        return digest.uint64 > POW_THRESHOLD
    }
    
    static func generate(_ hash: String) -> String? {
        guard let hash = hash.hexData else { return nil }
        var generated = false
        var resultData: Data = Data(count: 8)
        while !generated {
            guard let randomData = NaCl.randomBytes(8) else { return nil }
            var randomBytes = [UInt8](randomData)
            for i in 0..<256 {
                randomBytes[7] = UInt8((UInt32(randomBytes[7]) + UInt32(i)) % 256)
                guard let digest = NaCl.digest([Data(bytes: randomBytes), hash], outputLength: 8) else { return nil }
                if digest.uint64 > POW_THRESHOLD {
                    resultData = Data(bytes: randomBytes).byteSwap()
                    generated = true
                    break
                }
            }
        }
        return resultData.hexString
    }
}
