//
//  WalletUtil.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 12/17/17.
//  Copyright © 2017 Planar Form. All rights reserved.
//

import Foundation

enum WalletUtilError: Error {
    // Occrus when Sodium returns nil or performs an unsuccessful operation
    case internalSodium
    
    // Occurs when a 5-bit sequence was not found in the base32 lookup table
    case encoding
    
    // Occurs when invalid seed data is passed in
    case invalidSeedLength(Int)
}

struct WalletUtil {
    
    /// Gets the public/secret key pair from a given seed.
    ///
    /// Parameter secret: A 32 byte secret key as hex data.
    /// Parameter index: A value [0, 2^32-1] that's hashed together with the secret.
    ///
    /// Returns: A tuple containing the public and secret keys as Strings.
    static func keyPair(seed: Data, index: UInt32) -> KeyPair? {
        guard seed.count == SECRET_KEY_BYTES else {
            return nil
        }
        guard let secret = NaCl.digest([seed, Data(bytes: Data(index).reversed())]) else { return nil }
        return NaCl.keyPair(from: secret)
    }
    
    static func validate(address: String) -> Bool {
        return derivePublic(from: address) != nil
    }
    
    static func derivePublic(from xrbAccount: String) -> String? {
        let xrbPrefix = xrbAccount.prefix(4)
        let nanoPrefix = xrbAccount.prefix(5)
        var offset: Int = 0
        if xrbPrefix == "xrb_" {
            guard xrbAccount.count == 64 else {
                return nil
            }
            offset = 4
        } else if nanoPrefix == "nano_" {
            guard xrbAccount.count == 65 else {
                return nil
            }
            offset = 5
        } else {
            return nil
        }
        let letters = "13456789abcdefghijkmnopqrstuwxyz"
        var lookup: [Character: UInt8] = [:]
        for i in 0..<32 {
            lookup[letters[String.Index(encodedOffset: i)]] = UInt8(i)
        }
        
        let pubEnd = String.Index(encodedOffset: xrbAccount.endIndex.encodedOffset - 9)
        let pubStart = String.Index(encodedOffset: xrbAccount.startIndex.encodedOffset + offset)
        let encodedKey: String = String(xrbAccount[pubStart...pubEnd])
        let encodedChecksum: String = String(xrbAccount.suffix(8))
        
        var pubKeyBits: BitArray = BitArray()
        for i in 0..<encodedKey.count {
            // 5 bit value
            guard let value = lookup[encodedKey[String.Index(encodedOffset: i)]] else { return nil }
            for j in (0..<5).reversed() {
                pubKeyBits.append((1 << j) & value != 0)
            }
        }
        // Ignore first 4 bits since they're just hockey pads
        pubKeyBits = BitArray(pubKeyBits.suffix(from: 4))
        
        var checksumBits: BitArray = BitArray()
        for i in 0..<encodedChecksum.count {
            guard let value = lookup[encodedChecksum[String.Index(encodedOffset: i)]] else { return nil }
            for j in (0..<5).reversed() {
                checksumBits.append((1 << j) & value != 0)
            }
        }
        
        let checksumData = Data(bytes: checksumBits.byteArray).byteSwap()
        let result = Data(pubKeyBits.byteArray).hexString
        let digest = NaCl.hash(Data(bytes: pubKeyBits.byteArray), outputLength: 5)
        guard digest?.hexString == checksumData.hexString else { return nil }
        return result
    }
    
    /// Derives the XRB wallet account given an ED25519 public key string. The public key is hashed using Blake2b.
    ///
    /// XRB wallet address contains the following:
    ///     - prefix (xrb_ or nano_)
    ///     - address (260 bit)
    ///     - checksum (last 40 bit of public key hash)
    /// - Parameter publicKey: The public key to derive the XRB wallet address from.
    ///
    /// - Returns: The XRB wallet account
    static func deriveXRBAccount(from publicKey: Data) throws -> String {
        // Checksum should have a 5 byte digest size
        guard let checksumHash = NaCl.hash(publicKey, outputLength: 5) else {
            throw WalletUtilError.internalSodium
        }
        
        var pubKeyBitArray = publicKey.bitArray
        let checksumBitArray = checksumHash.byteSwap().bitArray
        
        // Insert padding for 256-bit -> 260 bit
        while pubKeyBitArray.count < 260 {
            pubKeyBitArray.insert(false, at: 0)
        }
        
        let encodedPubKey = encode(pubKeyBitArray)
        let encodedChecksum = encode(checksumBitArray)
        guard let encodedP = encodedPubKey, let encodedC = encodedChecksum else {
            throw WalletUtilError.encoding
        }
        return "xrb_" + encodedP + encodedC
    }
    
    /// Encodes a bit array using Base 32 encoding with 5-bit chunks.
    ///
    /// - Parameter bitArray: The bit array to encode. If encoding a checksum, this should be 40 bits, if encoding a public key hash, this should be 260 bits (4 bit padding included)
    /// - Returns: The encoded string or nil if a 5-bit sequence didn't result in an alphabet lookup hit.
    static func encode(_ bitArray: BitArray) -> String? {
        let letters = "13456789abcdefghijkmnopqrstuwxyz"
        var lookup: [UInt8: Character] = [:]
        for i in 0..<32 {
            lookup[UInt8(i)] = letters[String.Index(encodedOffset: i)]
        }
        var result: [Character] = []
        
        // Parse bit array in 5 bit chunks
        var i: Int = 0
        while i < bitArray.count {
            let start = bitArray.index(i, offsetBy: 0)
            let end = bitArray.index(i + 5, offsetBy: 0)
            let substring = bitArray[start..<end]
            let bitSequence = substring.map({ UInt8($0 ? 1 : 0) })
            if let c = lookup[UInt8.from(sequence: bitSequence)] {
                result.append(c)
            } else {
                return nil
            }
            i += 5
        }
        return String(result)
    }
}

extension BitArray {
    public var binaryString: String {
        return self.reversed().map { return $0 ? "1" : "0" }.joined(separator: "")
    }
}

extension Data {
    var bitArray: BitArray {
        var result: BitArray = BitArray()
        self.forEach {
            var mask: UInt8 = 1 << 7
            for _ in 0..<8 {
                result.append(mask & $0 != 0)
                mask >>= 1
            }
        }
        
        return result
    }
}
