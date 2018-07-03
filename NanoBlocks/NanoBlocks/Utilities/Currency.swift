//
//  Currency.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 2/10/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import Foundation

enum Currency: String {
    case aud
    case brl
    case cad
    case chf
    case clp
    case cny
    case czk
    case dkk
    case eur
    case gbp
    case hkd
    case huf
    case idr
    case ils
    case inr
    case jpy
    case krw
    case mxn
    case myr
    case nok
    case nzd
    case php
    case pkr
    case pln
    case rub
    case sek
    case sgd
    case thb
    case twd
    case usd
    case zar
    case lambo
    
    static var all: [Currency] {
        return [.usd, .eur, .jpy, .krw, .lambo, .aud, .brl, .cad, .chf, .clp, .cny, .czk, .dkk, .gbp, .hkd, .huf, .idr, .ils, .inr, .mxn, .myr, .nok, .nzd, .php, .pkr, . pln, .rub, .sek, .sgd, .thb, .twd, .zar]
    }
    
    var precision: Int {
        switch self {
        case .jpy, .krw: return 0
        case .lambo: return 6
        default: return 2
        }
    }
    
    var symbol: String {
        switch self {
        case .usd, .sgd, .cad, .hkd, .nzd, .mxn, .clp: return "$"
        case .eur: return "€"
        case .jpy, .cny: return "¥"
        case .krw: return "₩"
        case .aud: return "AU$"
        case .brl: return "R$"
        case .chf: return "CHF"
        case .czk: return "Kč"
        case .dkk, .nok, .sek: return "kr"
        case .gbp: return "£"
        case .huf: return "Ft"
        case .idr: return "Rp"
        case .ils: return "₪"
        case .inr: return "INR"
        case .myr: return "RM"
        case .php: return "₱"
        case .pkr: return "₨"
        case .pln: return "zł"
        case .rub: return "₽"
        case .thb: return "฿"
        case .twd: return "NT$"
        case .zar: return "R"
        case .lambo: return "LAMBO"
        }
    }
    
    /// Converts a Nano (either raw or mxrb) amount to the user's selected 'secondary' currency.
    func convert(_ value: BDouble, isRaw: Bool = true) -> String {
        let value = isRaw ? value.toMxrbValue : value
        return (Currency.secondaryConversionRate * value).decimalExpansion(precisionAfterComma: self.precision)
    }
    
    func convertToFiat(_ value: BDouble, isRaw: Bool = true) -> String {
        let value = isRaw ? value.toMxrb : value.decimalExpansion(precisionAfterComma: 6)
        return ((Double(value) ?? 0.0) * Currency.secondaryConversionRate).chopDecimal(to: Currency.secondary.precision)
    }
    func setRate(_ rate: Double) {
        UserDefaults.standard.set(rate, forKey: .kSecondaryConversionRate)
        UserDefaults.standard.synchronize()
    }
    
    func setAsSecondaryCurrency(with rate: Double) {
        UserDefaults.standard.set(self.rawValue, forKey: .kSecondaryCurrency)
        UserDefaults.standard.set(rate, forKey: .kSecondaryConversionRate)
        UserDefaults.standard.synchronize()
    }
    
    static var secondary: Currency {
        let currRaw = UserDefaults.standard.value(forKey: .kSecondaryCurrency) as? String ?? ""
        return Currency(rawValue: currRaw) ?? .usd
    }
    
    static var secondaryConversionRate: Double {
        return UserDefaults.standard.value(forKey: .kSecondaryConversionRate) as? Double ?? 1.0
    }
}

extension String {
    static let kSecondaryCurrency: String = "kSecondaryCurrency"
    static let kSecondaryConversionRate: String = "kSecondaryConversionRate"
}
