//
//  BIP39.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 12/22/17.
//  Copyright © 2017 Planar Form. All rights reserved.
//

import Foundation

struct BIP39 {
    private(set) var wordList: [String]
    
    init() {
        let path = Bundle.main.path(forResource: "BIP39Words", ofType: "plist", inDirectory: nil, forLocalization: Locale.current.identifier)
        let items = NSArray(contentsOfFile: path ?? "") as? [String]
        wordList = items?.flatMap { $0 } ?? []
    }
    
    // TODO: Use actual BIP39 impl (entropy) to generate mnemonic
    func generateMnemonic(_ wordCount: Int = 12) -> [String] {
        var result: [String] = []
        for _ in 0..<wordCount {
            let idx = Int(arc4random_uniform(UInt32(wordList.count - 1)))
            result.append(wordList[idx])
        }
        
        return result
    }
}
