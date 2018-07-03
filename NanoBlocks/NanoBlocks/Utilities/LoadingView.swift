//
//  LoadingView.swift
// NanoBlocks
//
//  Created by Ben Kray on 3/23/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import UIKit
import Lottie

class LoadingView {
    
    fileprivate static var containerView: UIView?
    fileprivate static var animatingView: LOTAnimationView?
    static fileprivate(set) var isAnimating: Bool = false
    
    static func startAnimating(in viewController: UIViewController?, dimView: Bool = false) {
        guard let viewController = viewController else { return }
        if isAnimating {
            cleanUp()
        }
        LoadingView.prepare(in: viewController, dims: dimView)
        animatingView?.play()
        isAnimating = true
    }
    
    static func stopAnimating(_ transition: Bool = false, completion: (() -> Void)? = nil) {
        animatingView?.stop()
        if transition {
            animatingView?.loopAnimation = false
            animatingView?.play(fromFrame: 151, toFrame: 240, withCompletion: { (_) in
                animatingView?.stop()
                cleanUp()
                completion?()
            })
        } else {
            cleanUp()
        }
    }
    
    fileprivate static func cleanUp() {
        LoadingView.animatingView?.removeFromSuperview()
        LoadingView.containerView?.removeFromSuperview()
        containerView = nil
        animatingView = nil
        isAnimating = false
    }
    
    fileprivate static func prepare(in viewController: UIViewController, dims: Bool) {
        containerView = UIView(frame: viewController.view.bounds)
        containerView?.isUserInteractionEnabled = false
        containerView?.backgroundColor = dims ? .black : .clear
        if dims {
            containerView?.alpha = 0.2
        }
        guard let container = containerView else { return }
        viewController.view.addSubview(container)
        animatingView = LOTAnimationView(name: "nano_loading_complete")
        animatingView?.play(fromFrame: 0, toFrame: 150)
        animatingView?.loopAnimation = true
        animatingView?.animationSpeed = 1.5
        animatingView?.translatesAutoresizingMaskIntoConstraints = false
        guard let animation = animatingView else { return }
        viewController.view.addSubview(animation)
        let centerH = NSLayoutConstraint(item: animation, attribute: .centerX, relatedBy: .equal, toItem: viewController.view, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        let centerY = NSLayoutConstraint(item: animation, attribute: .centerY, relatedBy: .equal, toItem: viewController.view, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        animation.heightAnchor.constraint(equalToConstant: 75).isActive = true
        animation.widthAnchor.constraint(equalToConstant: 75).isActive = true
        NSLayoutConstraint.activate([centerH, centerY])
    }
}
