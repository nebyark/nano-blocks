//
//  URLHandler.swift
// NanoBlocks
//
//  Created by Ben Kray on 2/26/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import Foundation

struct URLHandler {    
    static func parse(url: URL) -> PaymentInfo? {
        return parse(urlString: url.absoluteString.replacingOccurrences(of: "nanoblocks://", with: ""))
    }
    
    static func parse(urlString: String) -> PaymentInfo? {
        var amount: String?
        var address: String?
        // Example format: xrb:xrb_3wm37qz19zhei7nzscjcopbrbnnachs4p1gnwo5oroi3qonw6inwgoeuufdp?amount=1000
        guard urlString.prefix(4) == "xrb:" else { return nil }
        let components = URLComponents(string: urlString)
        for query in components?.queryItems ?? [] {
            if query.name == "amount" {
                amount = query.value
                break
            }
        }
        guard let addr = components?.path else { return nil }
        address = addr
        
        return PaymentInfo(amount: amount, address: address)
    }
}
