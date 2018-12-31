//
//  Common.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 1/13/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import Foundation

let STATEBLOCK_PREAMBLE: String = "0000000000000000000000000000000000000000000000000000000000000006"
let ZERO_AMT: String = "0000000000000000000000000000000000000000000000000000000000000000"
let LAMBO_PRICE: Double = 200000.0
let POW_THRESHOLD: UInt64 = 0xFFFFFFC000000000
let SECRET_KEY_BYTES: Int = 32
let BLOCK_EXPLORER_URL = "https://nanode.co/block/"
let DB_NAME: String = "my-little-db"
let EXPONENT: Int16 = 30

extension String {

    var decimalNumber: NSDecimalNumber {
        return NSDecimalNumber(string: self)
    }

    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 6
        formatter.minimumFractionDigits = 0
        formatter.minimumIntegerDigits = 1

        guard let value = Double(self) else {
            return "--"
        }

        return formatter.string(from: NSNumber(value: value)) ?? "--"
    }

}

extension Double {
    
    var toMxrb: String {
        let value = self / 1000000000000000000000000000000.0
        return String(format: "%.6f", value).trimTrailingZeros()
    }
    
    var toRaw: String {
        let raw = self * 1000000
        return String(Int(raw)) + "000000000000000000000000"
    }
}

extension NSDecimalNumber {

    fileprivate func nanoFormatter(_ digits: Int) -> NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.roundingMode = .floor
        numberFormatter.maximumFractionDigits = 6
        numberFormatter.minimumFractionDigits = 0
        return numberFormatter
    }

    var mxrbAmount: NSDecimalNumber {
        let divider = NSDecimalNumber(mantissa: 1, exponent: EXPONENT, isNegative: false)
        return self.dividing(by: divider)
    }

    var mxrbString: String {
        let result = self.mxrbAmount
        return self.nanoFormatter(6).string(from: result) ?? "0"
    }

    var rawValueAsDouble: Double? {
        return Double(self.rawString.replacingOccurrences(of: Locale.current.decimalSeparator ?? ",", with: "."))
    }

    var rawValue: NSDecimalNumber {
        return self.multiplying(byPowerOf10: EXPONENT)
    }

    var rawString: String {
        return self.rawValue.stringValue
    }

    var hexString: String? {
        var result = self
        var hex = ""
        let index = hex.startIndex

        while result.compare(0) == .orderedDescending {
            let handler = NSDecimalNumberHandler(roundingMode: .down, scale: 0, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
            let quotient = result.dividing(by: 16, withBehavior: handler)
            let subtractAmount = quotient.multiplying(by: 16)

            let remainder = result.subtracting(subtractAmount).intValue

            switch remainder {
            case 0...9: hex.insert(String(remainder).first!, at: index)
            case 10:    hex.insert("A", at: index)
            case 11:    hex.insert("B", at: index)
            case 12:    hex.insert("C", at: index)
            case 13:    hex.insert("D", at: index)
            case 14:    hex.insert("E", at: index)
            case 15:    hex.insert("F", at: index)

            default:
                return nil
            }

            result = quotient
        }

        return hex
    }
}
