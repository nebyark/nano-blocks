//
//  Secure.swift
//  NanoBlocks
//
//  Created by Ben Kray on 5/3/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import Foundation
import Sodium

protocol Secure {
    static func randomBytes(_ length: Int) -> Data?
    static func sign(_ data: Data, secret: Data) -> Data?
    static func hash(_ data: Data, outputLength: Int) -> Data?
    static func digest(_ items: [Data], outputLength: Int) -> Data?
    static func hash(_ data: Data, salt: Data) -> Data?
    static func decrypt(_ ciphered: Data, secret: Data) -> Data?
    static func encrypt(_ message: Data, secret: Data) -> Data?
    static func keyPair(from secret: Data) -> KeyPair?
    static func verify(_ data: Data, signature: Data, publicKey: Data) -> Bool
}

struct NaCl: Secure {
    static var saltBytes: Int {
        return Sodium().pwHash.SaltBytes
    }
    
    static func randomBytes(_ length: Int = 32) -> Data? {
        return Sodium().randomBytes.buf(length: length)
    }
    
    static func sign(_ data: Data, secret: Data) -> Data? {
        return Sodium().sign.signature(message: data, secretKey: secret)
    }
    
    static func hash(_ data: Data, outputLength: Int = 32) -> Data? {
        return Sodium().genericHash.hash(message: data, outputLength: outputLength)
    }
    
    static func digest(_ items: [Data], outputLength: Int = 32) -> Data? {
        let sodium = Sodium()
        guard let stream = sodium.genericHash.initStream(outputLength: outputLength) else { return nil }
        let success = items.reduce(true) { (previous, data) in
            return previous && stream.update(input: data)
        }
        guard success else { return nil }
        return stream.final()
    }
    
    static func hash(_ data: Data, salt: Data) -> Data? {
        let sodium = Sodium()
        let ops = sodium.pwHash.OpsLimitInteractive
        let mem = sodium.pwHash.MemLimitInteractive
        return sodium.pwHash.hash(outputLength: 32, passwd: data, salt: salt, opsLimit: ops, memLimit: mem)
    }
    
    static func decrypt(_ ciphered: Data, secret: Data) -> Data? {
        return Sodium().secretBox.open(nonceAndAuthenticatedCipherText: ciphered, secretKey: secret)
    }
    
    static func encrypt(_ message: Data, secret: Data) -> Data? {
        return Sodium().secretBox.seal(message: message, secretKey: secret)
    }
    
    static func keyPair(from secret: Data) -> KeyPair? {
        let pair = Sodium().sign.keyPair(secret: secret)
        guard let pub = pair?.publicKey, let secret = pair?.secretKey else { return nil }
        return KeyPair(publicKey: pub, secretKey: secret)
    }
    
    static func verify(_ data: Data, signature: Data, publicKey: Data) -> Bool {
        return Sodium().sign.verify(message: data, publicKey: publicKey, signature: signature)
    }
    static func zero(_ data: inout Data?) {
        guard var data = data else { return }
        Sodium().utils.zero(&data)
    }
}
