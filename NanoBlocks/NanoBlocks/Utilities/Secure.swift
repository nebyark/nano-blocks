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
        if let bytes = Sodium().randomBytes.buf(length: length) {
            return Data(bytes)
        }
        return nil
    }
    
    static func sign(_ data: Data, secret: Data) -> Data? {
        if let signature = Sodium().sign.signature(message: [UInt8](data), secretKey: [UInt8](secret)) {
            return Data(signature)
        }
        return nil
    }
    
    static func hash(_ data: Data, outputLength: Int = 32) -> Data? {
        if let hash = Sodium().genericHash.hash(message: [UInt8](data), outputLength: outputLength) {
            return Data(hash)
        }
        return nil
    }
    
    static func digest(_ items: [Data], outputLength: Int = 32) -> Data? {
        let sodium = Sodium()
        guard let stream = sodium.genericHash.initStream(outputLength: outputLength) else { return nil }
        let success = items.reduce(true) { (previous, data) in
            return previous && stream.update(input: [UInt8](data))
        }
        guard success, let hash = stream.final() else { return nil }
        return Data(hash)
    }
    
    static func hash(_ data: Data, salt: Data) -> Data? {
        let sodium = Sodium()
        let ops = sodium.pwHash.OpsLimitInteractive
        let mem = sodium.pwHash.MemLimitInteractive
        if let hash = sodium.pwHash.hash(outputLength: 32, passwd: [UInt8](data), salt: [UInt8](salt), opsLimit: ops, memLimit: mem) {
            return Data(hash)
        }
        return nil
    }
    
    static func decrypt(_ ciphered: Data, secret: Data) -> Data? {
        if let message = Sodium().secretBox.open(nonceAndAuthenticatedCipherText: [UInt8](ciphered), secretKey: [UInt8](secret)) {
            return Data(message)
        }
        return nil
    }
    
    static func encrypt(_ message: Data, secret: Data) -> Data? {
        if let encrypted: Bytes = Sodium().secretBox.seal(message: [UInt8](message), secretKey: [UInt8](secret)) {
            return Data(encrypted)
        }
        return nil
    }
    
    static func keyPair(from secret: Data) -> KeyPair? {
        let pair = Sodium().sign.keyPair(secret: secret)
        guard let pub = pair?.publicKey, let secret = pair?.secretKey else { return nil }
        return KeyPair(publicKey: Data(pub), secretKey: Data(secret))
    }
    
    static func verify(_ data: Data, signature: Data, publicKey: Data) -> Bool {
        return Sodium().sign.verify(message: [UInt8](data), publicKey: [UInt8](publicKey), signature: [UInt8](signature))
    }
    static func zero(_ data: inout Array<UInt8>?) {
        guard var data = data else { return }
        Sodium().utils.zero(&data)
    }
}
