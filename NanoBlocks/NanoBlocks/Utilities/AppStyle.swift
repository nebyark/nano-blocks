//
//  AppStyle.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 1/7/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import UIKit

struct AppStyle {

    struct Size {
        /// 30.0
        static var largePadding: CGFloat = 30.0
        /// 25.0
        static var mediumPadding: CGFloat = 25.0
        /// 20.0
        static var padding: CGFloat = 20.0
        /// 8.0
        static var smallPadding: CGFloat = 8.0

        /// 45.0
        static var control: CGFloat = 45.0
    }

    struct Font {
        /// 25.0, medium
        static var title: UIFont = .systemFont(ofSize: 25.0, weight: .medium)
        /// 17.0, light
        static var body: UIFont = .systemFont(ofSize: 17.0, weight: .light)
        /// 17.0, medium
        static var control: UIFont = .systemFont(ofSize: 17.0, weight: .medium)
    }

    struct Color {
        // 43, 45, 53
        static var offBlack = #colorLiteral(red: 0.168627451, green: 0.1764705882, blue: 0.2078431373, alpha: 1)
        // 43, 49, 101
        static var deepBlue = #colorLiteral(red: 0.168627451, green: 0.1921568627, blue: 0.3960784314, alpha: 1)
        // 2, 170, 224
        static var nanoBlue = #colorLiteral(red: 0.007843137255, green: 0.6666666667, blue: 0.8784313725, alpha: 1)
        
        static var lowAlphaBlack: UIColor {
            return UIColor.black.withAlphaComponent(0.6)
        }
        
        static var superLowAlphaBlack: UIColor {
            return UIColor.black.withAlphaComponent(0.1)
        }
        
        static var lowAlphaWhite: UIColor {
            return UIColor.white.withAlphaComponent(0.6)
        }
    }
    
    // Add colors and UI helpers here
    static var lightGrey: UIColor {
        return UIColor.gray.withAlphaComponent(0.5)
    }
    
    static var buttonGradient: CAGradientLayer {
        let gradient = CAGradientLayer()
        let start: CGColor = UIColor(rgb: 5, green: 174, blue: 225, alpha: 1.0).cgColor
        let end: CGColor = UIColor(rgb: 13, green: 125, blue: 221, alpha: 1.0).cgColor
        gradient.colors = [start, end]
        gradient.startPoint = CGPoint(x: 0, y: 1)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        return gradient
    }
}
