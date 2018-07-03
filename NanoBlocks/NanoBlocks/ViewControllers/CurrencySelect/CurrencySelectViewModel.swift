//
//  CurrencySelectViewModel.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 2/11/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import Foundation

struct CurrencySelectViewModel {
    private(set) var currencies: [Currency] = Currency.all
    
    subscript(_ index: Int) -> Currency? {
        guard index < currencies.count else { return nil }
        return currencies[index]
    }
}
