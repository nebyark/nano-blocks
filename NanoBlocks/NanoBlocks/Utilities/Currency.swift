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
    case btc
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
        return [.btc, .usd, .eur, .jpy, .krw, .lambo, .aud, .brl, .cad, .chf, .clp, .cny, .czk, .dkk, .gbp, .hkd, .huf, .idr, .ils, .inr, .mxn, .myr, .nok, .nzd, .php, .pkr, . pln, .rub, .sek, .sgd, .thb, .twd, .zar]
    }
    
    var precision: Int {
        switch self {
        case .jpy, .krw: return 0
        case .lambo: return 6
        case .btc: return 8
        default: return 2
        }
    }
    
    var symbol: String {
        switch self {
        case .usd, .sgd, .cad, .hkd, .nzd, .mxn, .clp: return "$"
        case .btc: return "₿"
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
    
    /// The currency value type, while stripping redundancies (like LAMBO, chf, etc)
    var typePostfix: String {
        var base = rawValue.uppercased()
        if rawValue.uppercased() != symbol.uppercased() {
            base += " (\(symbol))"
        }
        return base
    }
    
    /// Converts a Nano (either raw or mxrb) amount to the user's selected 'secondary' currency.
    func convert(_ value: NSDecimalNumber, isRaw: Bool = true) -> String {
        let value = isRaw ? value.mxrbAmount : value
        let conversionRate = Decimal(Currency.secondaryConversionRate)
        let convertedValue = value.multiplying(by: NSDecimalNumber(decimal: conversionRate))
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = self.precision
        numberFormatter.minimumFractionDigits = self.precision
        numberFormatter.numberStyle = .decimal

        let numberValue = NSNumber(value: convertedValue.doubleValue)
        return numberFormatter.string(from: numberValue) ?? "--"
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

    static func setSecondary(_ selected: Bool) {
        if selected {
            UserDefaults.standard.set(true, forKey: .kSecondarySelected)
        } else {
            UserDefaults.standard.removeObject(forKey: .kSecondarySelected)
        }
    }

    static var secondary: Currency {
        let currRaw = UserDefaults.standard.value(forKey: .kSecondaryCurrency) as? String ?? ""
        return Currency(rawValue: currRaw) ?? .usd
    }
    
    static var secondaryConversionRate: Double {
        return UserDefaults.standard.value(forKey: .kSecondaryConversionRate) as? Double ?? 1.0
    }

    static var isSecondarySelected: Bool {
        return UserDefaults.standard.value(forKey: .kSecondarySelected) != nil
    }
}

extension String {
    static let kSecondaryCurrency: String = "kSecondaryCurrency"
    static let kSecondaryConversionRate: String = "kSecondaryConversionRate"
    static let kSecondarySelected: String = "kSecondarySelected"
}
