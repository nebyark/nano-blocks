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
let RAW_XRB: BDouble = BDouble("1000000000000000000000000000000")!
let SECRET_KEY_BYTES: Int = 32
let BLOCK_EXPLORER_URL = "https://nanode.co/block/"
let DB_NAME: String = "my-little-db"

extension BDouble {
    var toRaw: BDouble {
        return self * RAW_XRB
    }
    var toMxrb: String {
        let expanded = (self / RAW_XRB).decimalExpansion(precisionAfterComma: 30)
        guard let expandedValue = Double(expanded) else { return "" }
        return String(format: "%.6f", expandedValue)
    }
    var toMxrbValue: BDouble {
        return toMxrb.bNumber
    }
}

extension String {
    var bNumber: BDouble {
        return BDouble(self) ?? BDouble(0)
    }
}

extension Double {
    var bNumber: BDouble {
        return BDouble(self)
    }
    
    var toMxrb: String {
        let value = self / 1000000000000000000000000000000.0
        return String(format: "%.6f", value).trimTrailingZeros()
    }
    
    var toRaw: String {
        let raw = self * 1000000
        return String(Int(raw)) + "000000000000000000000000"
    }
}
