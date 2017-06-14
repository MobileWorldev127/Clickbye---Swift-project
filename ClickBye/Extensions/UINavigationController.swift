//
//  UINavigationController.swift
//  ClickBye
//
//  Created by Yuriy Berdnikov on 3/17/17.
//  Copyright © 2017 Maxim. All rights reserved.
//

import UIKit

extension UINavigationController {
    // MARK - Push
    func push<ViewController: UIViewController>(_ controllerDetails: ViewController.Type,
              animated: Bool = true,
              configuration: ((_ viewController: ViewController) -> Void)? = nil,
              completion: ((_ viewController: ViewController) -> Void)? = nil) where ViewController: ViewControllerDescribable {
        guard let viewController = UIStoryboard.initialized(with: controllerDetails.storyboardName).instantiateViewController(withIdentifier: controllerDetails.viewControllerId) as? ViewController else {
            return
        }
        
        configuration?(viewController)
        
        pushViewController(viewController, animated: animated)
        
        completion?(viewController)
    }
}
