//
//  UIKit+Extensions.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 12/22/17.
//  Copyright © 2017 Planar Form. All rights reserved.
//

import UIKit
import CoreGraphics

extension UIImage {
    // Note: original implementation from breadwallet's app:
    static func qrCode(data: Data?, color: CIColor) -> UIImage? {
        guard let data = data else { return nil }
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")
        let maskFilter = CIFilter(name: "CIMaskToAlpha")
        let invertFilter = CIFilter(name: "CIColorInvert")
        let colorFilter = CIFilter(name: "CIFalseColor")
        var filter = colorFilter
        
        qrFilter?.setValue(data, forKey: "inputMessage")
        qrFilter?.setValue("L", forKey: "inputCorrectionLevel")
        
        let inputKey = "inputImage"
        if Double(color.alpha) > .ulpOfOne {
            invertFilter?.setValue(qrFilter?.outputImage, forKey: inputKey)
            maskFilter?.setValue(invertFilter?.outputImage, forKey: inputKey)
            invertFilter?.setValue(maskFilter?.outputImage, forKey: inputKey)
            colorFilter?.setValue(invertFilter?.outputImage, forKey: inputKey)
            colorFilter?.setValue(color, forKey: "inputColor0")
        } else {
            maskFilter?.setValue(qrFilter?.outputImage, forKey: inputKey)
            filter = maskFilter
        }
        
        let context = CIContext(options: [CIContextOption.useSoftwareRenderer: true])
        objc_sync_enter(context)
        defer { objc_sync_exit(context) }
        guard let outputImage = filter?.outputImage else { return nil }
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
    func resize(_ size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        guard let cgImage = self.cgImage else { return nil }
        
        context.interpolationQuality = .none
        context.rotate(by: .pi)
        context.scaleBy(x: -1.0, y: 1.0)
        context.draw(cgImage, in: context.boundingBoxOfClipPath)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func maskWithColor(_ color: UIColor) -> UIImage? {
        guard let maskImage = cgImage else { return nil }
        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        
        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)
        
        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }
}

extension UIColor {
    convenience init(rgb: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        self.init(red: rgb/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
    }
}

extension UINavigationBar {
    func makeTransparent() {
        setBackgroundImage(UIImage(), for: .default)
        shadowImage = UIImage()
        isTranslucent = true
    }
}

extension UITableView {
    func register<T: Identifiable>(_ cellType: T.Type) {
        let nib = UINib(nibName: cellType.identifier, bundle: nil)
        register(nib, forCellReuseIdentifier: cellType.identifier)
    }
    
    func register(_ reuseIdentifier: String) {
        let nib = UINib(nibName: reuseIdentifier, bundle: nil)
        register(nib, forCellReuseIdentifier: reuseIdentifier)
    }
    
    func dequeueReusableCell<T: Identifiable>(_ cellType: T.Type, for indexPath: IndexPath) -> T {
        let cell = dequeueReusableCell(withIdentifier: T.identifier, for: indexPath)
        
        if rowHeight == UITableView.automaticDimension {
            // resize frame
            cell.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
            cell.layoutIfNeeded()
        }
        
        return cell as! T
    }
    
    func reloadData(completion handler: @escaping () -> Void) {
        UIView.animate(withDuration: 0, animations: {
            self.reloadData()
        }) { _ in
            // On complete
            handler()
        }
    }
}

extension UIViewController {
    
    static var topMost: UIViewController? {
        var top = UIApplication.shared.keyWindow?.rootViewController
        while top?.presentedViewController != nil {
            top = top?.presentedViewController
        }
        return top
    }
    
    func showTextDialogue(_ message: String, placeholder: String, keyboard: UIKeyboardType = .decimalPad, completion: @escaping (UITextField) -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
            textField.autocapitalizationType = .words
            textField.placeholder = placeholder
            textField.keyboardType = keyboard
        })
        let enterAction = UIAlertAction(title: "Enter", style: .default) { _ in
            guard let textField = alertController.textFields?.first else { return }
            completion(textField)
        }
        let cancelAction = UIAlertAction(title: String.localize("cancel"), style: .cancel, handler: nil)
        alertController.addAction(enterAction)
        alertController.preferredAction = enterAction
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
}

extension UIDevice {
    static var isIPhoneX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }
}

extension UITabBar {
    func orderedTabBarItemViews() -> [UIView] {
        let interactionViews = self.subviews.filter({$0.isUserInteractionEnabled})
        return interactionViews.sorted(by: {$0.frame.minX < $1.frame.minX})
    }
    
    func frame(forItemAt index: Int) -> CGRect {
        let views = orderedTabBarItemViews()
        guard index < views.count else { return .zero }
        return views[index].frame
    }
}

protocol FromNib {
    func viewFromNib() -> UIView
    func setupView(frame: CGRect?)
}

extension UIView: FromNib {
    func viewFromNib() -> UIView {
        return UINib(nibName: String(describing: type(of: self)), bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
    }
    
    func setupView(frame: CGRect? = nil) {
        let deviceView = viewFromNib()
        deviceView.autoresizingMask = [.flexibleWidth, .flexibleWidth]
        if let f = frame {
            deviceView.frame = f
        } else {
            deviceView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        }
        addSubview(deviceView)
    }
}

extension UIView {
    func mask(viewToMask: UIView, maskRect: CGRect, invert: Bool = false, cornerRadius: CGFloat = 0.0) {
        let maskLayer = CAShapeLayer()
        let path = CGMutablePath()
        if (invert) {
            path.addRect(viewToMask.bounds)
        }
        if cornerRadius > 0.0 {
            let rounded = UIBezierPath(roundedRect: maskRect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
            path.addPath(rounded.cgPath)
        } else {
            path.addRect(maskRect)
        }
        
        maskLayer.path = path
        if (invert) {
            maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        }
        viewToMask.layer.mask = maskLayer;
    }
    
    func addShadow(_ intensity: Float = 0.2, radius: CGFloat = 3.0, offset: CGSize = CGSize(width: 0.0, height: 1.0)) {
        layer.masksToBounds = false
        layer.shadowRadius = radius
        layer.shadowOpacity = intensity
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = offset
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

extension UIEdgeInsets {
    static let noSeparator: UIEdgeInsets = UIEdgeInsets(top: 0, left: 10000, bottom: 0, right: 0)
}

extension UIButton {
    func toggle(_ shouldEnable: Bool, enableColor: UIColor, disableColor: UIColor) {
        isEnabled = shouldEnable
        backgroundColor = shouldEnable ? enableColor : disableColor
    }
    
    // Switching the title with animation will cause the UIButton to flash. To avoid the flash, set animated to false.
    func changeTitle(to value: String, animated: Bool = false) {
        if animated {
            setTitle(value, for: .normal)
        } else {
            UIView.performWithoutAnimation {
                setTitle(value, for: .normal)
                layoutIfNeeded()
            }
        }
    }
}

// MARK: - Identifier

protocol Identifiable {
    static var identifier: String { get }
}

extension Identifiable {
    static var identifier: String { return String(describing: self) }
}

extension Identifiable where Self: UIView {
    static func instantiate() -> Self {
        let view = Bundle.main.loadNibNamed(self.identifier, owner: self, options: nil)!.first
        return view as! Self
    }
}

extension UITableViewCell: Identifiable { }

extension UINib {
    convenience init<T: Identifiable>(_ type: T.Type, bundle: Bundle? = nil) {
        self.init(nibName: type.identifier, bundle: bundle)
    }
}
