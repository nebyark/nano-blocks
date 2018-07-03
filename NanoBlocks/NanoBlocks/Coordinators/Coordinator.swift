//
//  Coordinator.swift
//  Sawpy
//
//  Created by Ben Kray on 4/10/17.
//  Copyright © 2017 Planar Form. All rights reserved.
//

import Foundation
import UIKit

/// The Coordinator protocol
public protocol Coordinator: class {
    var childCoordinators: [Coordinator] { get set }
    func start()
}

extension Coordinator {
    func addChildCoordinator(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }
    
    func removeChildCoordinator(_ coordinator: Coordinator) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
    }
}

public protocol RootViewControllerProvider: class {
    var rootViewController: UIViewController { get }
}

/// A Coordinator type that provides a root UIViewController
public typealias RootViewCoordinator = Coordinator & RootViewControllerProvider
