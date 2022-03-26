//
//  Coordinator.swift
//  UpperOze
//
//  Created by gabriel durican on 3/23/22.
//

import Foundation
import UIKit

protocol Coordinator {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
}

class MainCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
//        let vc = ViewController.instantiate()
//        navigationController.pushViewController(vc, animated: false)
    }
}
