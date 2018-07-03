//
//  NanoBlocksSecureTests.swift
//  NanoBlocksTests
//
//  Created by Ben Kray on 5/9/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import XCTest
@testable import NanoBlocks

class NanoBlocksSecureTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSaltPassword() {
        // Given
        let password = "passwordistooshortbutnowitslong"
        let salt = NaCl.randomBytes(NaCl.saltBytes)!
        
        // When
        let salted = NaCl.hash(password.data(using: .utf8)!, salt: salt)
        // ... password check again
        let salted2 = NaCl.hash(password.data(using: .utf8)!, salt: salt)

        // Then
        XCTAssert(salted == salted2, "Salted passwords should be the same")
    }
    
    func testEncrypt() {
        // Given
        let secretMessage = "i know imma get got, but imma get mine more than i get got tho"
        let secretKey = NaCl.randomBytes(32)!
        
        // When
        let encrypted = NaCl.encrypt(secretMessage.data(using: .utf8)!, secret: secretKey)!
        let encrypted2 = NaCl.encrypt(secretMessage.data(using: .utf8)!, secret: NaCl.randomBytes(32)!)
        
        // Then
        XCTAssert(secretMessage != (String(data: encrypted, encoding: .utf8) ?? ""), "Secret message should not be the same as the encrypted message")
        XCTAssert(encrypted != encrypted2, "Ciphered messages with different encryption keys shouldn't be the same")
    }
    
    func testDecrypt() {
        // Given
        let secretMessage = "i know imma get got, but imma get mine more than i get got tho"
        let secretKey = NaCl.randomBytes(32)!
        let badKey = NaCl.randomBytes(32)!
        let encrypted = NaCl.encrypt(secretMessage.data(using: .utf8)!, secret: secretKey)!
        
        // When
        let decrypted = NaCl.decrypt(encrypted, secret: secretKey)!
        
        // Then
        XCTAssert(String(data: decrypted, encoding: .utf8)! == secretMessage)
        XCTAssert(NaCl.decrypt(encrypted, secret: badKey) == nil)
    }
    
    func testDigest() {
        // Given
        let preamble = "0000000000000000000000000000000000000000000000000000000000000006".hexData!
        let account = "41dc82d9db49ca71e500f1e609ae0f7b76c38b48f5eb977eb1548f7dd8cb3f7d".hexData!
        let previous = "e3baf821c8c6fd0941c3d3454c75d43ca01de0f4fa8916eef99def7baf4a65ab".hexData!
        let rep = "84d4c7e755aa7b1319de23d8cec1c55e7a319e473e5f2ec7413929e1525d79d9".hexData!
        let bal = "00000000000000000000000000000000".hexData!
        let link = "84d4c7e755aa7b1319de23d8cec1c55e7a319e473e5f2ec7413929e1525d79d9".hexData!
        
        // When
        let digest = NaCl.digest([preamble, account, previous, rep, bal, link], outputLength: 32)
        
        // Then
        XCTAssert(digest != nil)
        XCTAssert(digest?.hexString == "1edefc577975225a579a51c1732f4c405acf9f4eeedd59aa8e198fe29c30b4d6")
    }
}
