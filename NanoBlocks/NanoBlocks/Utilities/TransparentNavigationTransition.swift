//
//  TransparentNavigationTransition.swift
//
//  Created by Ben Kray on 9/11/17.
//  Copyright © 2017 Planar Form. All rights reserved.
//

import UIKit

class CustomInteractor: UIPercentDrivenInteractiveTransition {
    var navController: UINavigationController
    var shouldCompleteTransition = false
    var transitionInProgress = false
    
    init?(attachTo viewController: UIViewController) {
        if let nav = viewController.navigationController {
            self.navController = nav
            super.init()
            setupBackGesture(for: viewController.view)
        } else {
            return nil
        }
    }
    
    private func setupBackGesture(for view: UIView) {
        let swipeBackGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleBackGesture(_:)))
        swipeBackGesture.edges = .left
        view.addGestureRecognizer(swipeBackGesture)
    }
    
    @objc private func handleBackGesture(_ gesture: UIScreenEdgePanGestureRecognizer) {
        let viewTranslation = gesture.translation(in: gesture.view?.superview)
        let progress = viewTranslation.x / navController.view.frame.width
        switch gesture.state {
        case .began:
            transitionInProgress = true
            if gesture.velocity(in: gesture.view).x > 500 {
                navController.popViewController(animated: true)
            }
        case .changed:
            shouldCompleteTransition = progress > 0.5
            update(progress)
        case .cancelled:
            transitionInProgress = false
            cancel()
        case .ended:
            transitionInProgress = false
            shouldCompleteTransition ? finish() : cancel()
            if progress > 0.5 {
                navController.popViewController(animated: true)
            }
            break
        default:
            return
        }
    }
}

class TransparentNavigationTransition: NSObject, UIViewControllerAnimatedTransitioning {
    let operation: UINavigationController.Operation
    
    init(operation: UINavigationController.Operation) {
        self.operation = operation
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        guard let fromVC = transitionContext.viewController(forKey: .from), let toVC = transitionContext.viewController(forKey: .to) else { return }
        
        let fromView: UIView = fromVC.view
        let toView: UIView = toVC.view
        let containerWidth = container.frame.width
        var toFrame = container.frame
        var fromFrame = fromView.frame
        
        if operation == .push {
            toFrame.origin.x = containerWidth
            toView.frame = toFrame
            fromFrame.origin.x = -containerWidth
        } else if operation == .pop {
            toFrame.origin.x = -containerWidth
            toView.frame = toFrame
            fromFrame.origin.x = containerWidth
        }
        
        toVC.view.isUserInteractionEnabled = false
        toVC.view.removeFromSuperview()
        container.addSubview(toView)
        
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: [], animations: {
            toView.frame = container.frame
            fromView.frame = fromFrame
        }) { _ in
            toView.frame = container.frame
            toView.isUserInteractionEnabled = true
            fromView.removeFromSuperview()
            transitionContext.completeTransition(true)
        }
    }
}
