//
//  Foundaton+Extensions.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 12/16/17.
//  Copyright © 2017 Planar Form. All rights reserved.
//

import Foundation

extension UInt8 {
    static func from(sequence: [UInt8]) -> UInt8 {
        var value: UInt8 = 0
        sequence.forEach {
            value <<= 1
            value |= UInt8($0)
        }
        return value
    }
}

extension Double {
    func chopDecimal(to places: Int = 2) -> String {
        return String(format: "%.\(places)f", self)
    }
    
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
extension Data {
    init(_ int32: UInt32) {
        var i = int32
        self = Data(bytes: &i, count: 4)
    }
    
    init(_ int: Int) {
        var i = int
        self = Data(bytes: &i, count: 4)
    }
    
    func byteSwap() -> Data {
        var result = self
        var left: Int = 0
        var right: Int = self.count - 1
        while left < right {
            result.swapAt(left, right)
            left += 1
            right -= 1
        }
        
        return result
    }
    
    var hexString: String {
        return self.map { String(format: "%02hhx", $0) }.joined()
    }
    
    var uint32: UInt32 {
        return self.withUnsafeBytes { (ptr) -> UInt32 in
            ptr.pointee
        }
    }
    
    var uint64: UInt64 {
        return self.withUnsafeBytes { (ptr) -> UInt64 in
            ptr.pointee
        }
    }
}

extension String {
    // Trims trailing zeros on a price string.
    func trimTrailingZeros() -> String {
        var result = self
        if result.contains(".") {
            while result.count > 0 && result.suffix(1) == "0" {
                result = String(result.dropLast())
            }
            if result.suffix(1) == "." {
                result = String(result.dropLast())
            }
        }
        return result
    }
    
    static func localize(_ key: String, arg: String? = nil) -> String {
        if let arg = arg {
            return String(format: NSLocalizedString(key, comment: ""), arg)
        } else {
            return NSLocalizedString(key, comment: "")
        }
    }
    
    static func json(_ json: Any) -> String? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []) else { return nil }
        return String(data: jsonData, encoding: .ascii)
    }
    
    func leftPadding(toLength: Int, withPad character: Character) -> String {
        let newLength = self.count
        if newLength < toLength {
            return String(repeatElement(character, count: toLength - newLength)) + self
        } else {
            return String(self[index(self.startIndex, offsetBy: newLength - toLength)])
        }
    }
    
    var hexData: Data? {
        if self == "" { return Data() }
        var data = Data(capacity: self.count / 2)
        
        do {
            let regex = try NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
            regex.enumerateMatches(in: self, range: NSMakeRange(0, utf16.count)) { match, flags, stop in
                let byteString = (self as NSString).substring(with: match!.range)
                var num = UInt8(byteString, radix: 16)!
                data.append(&num, count: 1)
            }
            
        } catch {
            return nil
        }
        
        guard data.count > 0 else { return nil }
        
        return data
    }
}

protocol CaseCountable {
    static func countCases() -> Int
    static var caseCount : Int { get }
}

extension CaseCountable where Self : RawRepresentable, Self.RawValue == Int {
    static func countCases() -> Int {
        var count = 0
        while let _ = Self(rawValue: count) { count += 1 }
        return count
    }
}
