//
//  UIViewController.swift
//  ClickBye
//
//  Created by marydort on 2/26/17.
//  Copyright © 2017 Perpetio. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func showAlertControllerWithTitle(title: String, message: String) {
        let alertController = UIAlertController.alertWithTitle(title: title, message: message)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

extension UIViewController {
    // MARK: - Presentation
    func present<ViewController: UIViewController>(_ controllerDetails: ViewController.Type,
                 navigationEnabled: Bool = false,
                 animated: Bool = true,
                 configuration: ((_ viewController: ViewController) -> Void)? = nil,
                 completion: ((_ viewController: ViewController) -> Void)? = nil) where ViewController: ViewControllerDescribable {
        if navigationEnabled {
            guard let navigationControllerId = controllerDetails.navigationControllerId,
                let navigationController = UIStoryboard.initialized(with: controllerDetails.storyboardName).instantiateViewController(withIdentifier: navigationControllerId) as? UINavigationController,
                let viewController = navigationController.viewControllers.first as? ViewController else {
                    return
            }
            
            configuration?(viewController)
            
            present(navigationController, animated: animated, completion: {
                completion?(viewController)
            })
        } else {
            guard let viewController = UIStoryboard.initialized(with: controllerDetails.storyboardName).instantiateViewController(withIdentifier: controllerDetails.viewControllerId) as? ViewController else {
                return
            }
            
            configuration?(viewController)
            
            present(viewController, animated: animated, completion: {
                completion?(viewController)
            })
        }
    }
    
    func previewingViewController<ViewController: UIViewController>(_ controllerDetails: ViewController.Type,
                                  navigationEnabled: Bool = false,
                                  configuration: ((_ viewController: ViewController) -> Void)? = nil) -> ViewController? where ViewController: ViewControllerDescribable {
        if navigationEnabled {
            guard let navigationControllerId = controllerDetails.navigationControllerId,
                let navigationController = UIStoryboard.initialized(with: controllerDetails.storyboardName).instantiateViewController(withIdentifier: navigationControllerId) as? UINavigationController,
                let viewController = navigationController.viewControllers.first as? ViewController else {
                    return nil
            }
            
            configuration?(viewController)
            
            return viewController
        } else {
            guard let viewController = UIStoryboard.initialized(with: controllerDetails.storyboardName).instantiateViewController(withIdentifier: controllerDetails.viewControllerId) as? ViewController else {
                return nil
            }
            
            configuration?(viewController)
            
            return viewController
        }
    }
}
