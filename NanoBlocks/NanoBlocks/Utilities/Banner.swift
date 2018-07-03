//
//  Banner.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 1/30/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import Foundation
import NotificationBannerSwift

struct Banner {
    
    enum MessageType {
        case success
        case warning
        case error
    }
    
    static func show(_ message: String, title: String? = nil, style:  BannerStyle, in view: UIViewController? = nil) {
        let banner = NotificationBanner(title: message, subtitle: title, style: style)
        if let view = view {
            banner.show(on: view)
        } else {
            banner.show()
        }
    }
}
