//
//  NanoBlocksTests.swift
//  NanoBlocks
//
//  Created by Ben Kray on 3/6/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import XCTest
@testable import NanoBlocks

class NanoBlocksTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testImportSeed() {
        // Given
        let expectedAddress = "xrb_38ncappfy6i6mmz5kx93e6rh88tnx9ne68g644u88u9wjqwr3ua5jdrhqgxm"
        let seed = "3E8ABFC17DC5DE84B18935BB40FEB67FB409724B902E028736120AED3092DAEF"
        let expectedPublicKeyHex = "9a8a45acdf12049cfe3974e16130f31b54e9e8c219c410b6636cfc8df980ed03"
        
        // When
        let keyPair = WalletUtil.keyPair(seed: seed.hexData!, index: 0)
        
        // Then
        XCTAssert(expectedPublicKeyHex == keyPair?.publicKey.hexString)
        XCTAssert(expectedAddress == keyPair?.xrbAccount)
    }
    
    func testImportSeedNAccounts() {
        let addresses = [
            "xrb_38ncappfy6i6mmz5kx93e6rh88tnx9ne68g644u88u9wjqwr3ua5jdrhqgxm",
            "xrb_36p4xfxn365i9h7oxta6tdmu53zndrm45r3x9ag9naa3mxnnpn3p6tjfqzqm",
            "xrb_34ni44uj4xuy54nyhrbgjqsmi1yogpzqsgiiwz4a4huuzojz8g6a6tr1mu1m",
            "xrb_1dfsmb9gkaphtt7dyxu9idt3djxkdtnq6d6i4dqtk7irnjw39opkjamcp31t",
            "xrb_3ipekn3txsti19orp8mmo68uxet86bdc9y1to5pxnkdbt1tqot7jqes9i46p",
            "xrb_1faux9q4nsu63pma3htoix8rduajaradd5c6zhimoydcmya3pjipnmanzkee",
            "xrb_3ggswcjqrc8rqm8rr88gut9381p6iggs6pjw4g1gk4wtw7ak73ye4oiu8cik",
            "xrb_1rhff3zskquu4isx6456twxzai71y3tnekcayrk7b3uiyqg6hayzp5ybrbqd",
            "xrb_3f1r95waikrxqh75cedjtnah9k3hbbd5ykz4y8f77z1cbs1ywk1oysq6j8mx",
            "xrb_37bgk64u3ae98r989wyyo9kna3jtfc8teiw3acimjet9j38f4oid891gsxo3",
            "xrb_3y9andg1c7mdxu6fpgumzjdmk431q1jh3igdetwey4zc65p8byw3ggajgw9h",
            "xrb_1axc4durr9xhr5n65csr6n8foyzptr74eoe1613a4a7c5kru8b164h1qeumg",
            "xrb_35qcuzqsgwdph8dp1zjyrdzibtgj4pwu447sge9aior86d8apxjphmcescro",
            "xrb_3wu9npstir1upq8wzf9betxti9b1fxjr6mpko7e7dont7ksgic37a1iezng3",
            "xrb_1e1pmsftjj8h3uq98sjodk8ifsbmhyxy9psnio81d93x5e31f7srdfxx1oxj",
            "xrb_3hihqmudqfwm866r94ygn9nkrzo9ireof6bf4ukchd3jdwg91xeyrnpttbx1",
            "xrb_15w8aksuhbnb14q6r66x6hparoffpojbz1mz3id6kghtykcms95m8senuzpp"
        ]
        let seed = "3E8ABFC17DC5DE84B18935BB40FEB67FB409724B902E028736120AED3092DAEF"
        
        addresses.enumerated().forEach { (index, address) in
            let keyPair = WalletUtil.keyPair(seed: seed.hexData!, index: UInt32(index))
            XCTAssert(keyPair?.xrbAccount == address, "Expected \(address), got \(keyPair?.xrbAccount ?? "")")
        }
    }
    
    func testImportInvalidSeed() {
        // Given
        let expectedAddress = "xrb_38ncappfy6i6mmz5kx93e6rh88tnx9ne68g644u88u9wjqwr3ua5jdrhqgxm"
        let seed = "ZE8ABFC17DC5DE84B18935BB40FEB67FB409724B902E028736120AED3092DAEF"
        let expectedPublicKeyHex = "9a8a45acdf12049cfe3974e16130f31b54e9e8c219c410b6636cfc8df980ed03"
        
        // When
        let keyPair = WalletUtil.keyPair(seed: seed.hexData!, index: 0)
        
        // Then
        XCTAssert(expectedPublicKeyHex != keyPair?.publicKey.hexString)
        XCTAssert(expectedAddress != keyPair?.xrbAccount)
    }
    
    func testImportInvalidSeedLength() {
        // Given
        let seed = "ZEFC17DC5DE84B18935BB40FEB67FB409724B902E028736120AED3092DAEF"
        
        // When
        let keyPair = WalletUtil.keyPair(seed: seed.hexData!, index: 0)
        
        // Then
        XCTAssert(keyPair == nil)
    }
    
    func testVerifySignature() {
        var sig = "EAD10FAC0CD03321A4A398DD1F6158E96FFE9B536C6D77503E55B49E0BD32CF093FF8C8D26A5FBA3E67673D6539BD1D7224F6E2D25E0EF2555F94464C0DECA08"
        var blockHash = "DF5C29393236F50366D2DAA164C9E19C109446FBABEFEE5A074431FEC1A6CA39"
        var publicKey = "55813555ebc1c1b1f87c3b70848b1e22f23e64d5240f1ff34c81a49925d852f0"
        XCTAssert(NaCl.verify(blockHash.hexData!, signature: sig.hexData!, publicKey: publicKey.hexData!))
        
        // Fail on invalid public key
        publicKey = publicKey.replacingOccurrences(of: "b", with: "a")
        XCTAssert(!NaCl.verify(blockHash.hexData!, signature: sig.hexData!, publicKey: publicKey.hexData!))
        
        // Fail on invalid block hash
        blockHash = publicKey.replacingOccurrences(of: "C", with: "3")
        XCTAssert(!NaCl.verify(blockHash.hexData!, signature: sig.hexData!, publicKey: publicKey.hexData!))
        
        // Fail on invalid sig
        sig = sig.replacingOccurrences(of: "1", with: "A")
        XCTAssert(!NaCl.verify(blockHash.hexData!, signature: sig.hexData!, publicKey: publicKey.hexData!))
    }
    
    func testSignature() {
        // Given
        let value = "this is a test"
        let expectedSignature = "3998e7ef0eebc84cdf4c01ad45145b134dd435fca0894ec9691da517c06f1792088ce5486aeadaf8dde10bb72f20fd7578603c1c33d2e20c17b2ef5937f49a00"
        let keyPair = WalletUtil.keyPair(seed: "3E8ABFC17DC5DE84B18935BB40FEB67FB409724B902E028736120AED3092DAEF".hexData!, index: 0)!
        
        
        // When
        let signature = NaCl.sign(value.data(using: .utf8)!, secret: keyPair.secretKey)
        
        // Then
        XCTAssert(signature?.hexString == expectedSignature)
    }
    
    func testPublicKeyToAccount() {
        // Given
        let publicKey = "7FB7CB51A4D0E0846DDAB92186D235EE3442060EDE7030BBE05D50173D1DD2C2"
        
        // When
        let account = try? WalletUtil.deriveXRBAccount(from: publicKey.hexData!)
        
        // Then
        XCTAssert(account == "xrb_1zxqsfatbn91ijpxogb3iub5dujnaa51xqmi84xy1qci4wyjunp45y6abnw3")
    }
    
}
