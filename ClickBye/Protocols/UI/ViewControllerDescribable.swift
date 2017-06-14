//
//  ViewControllerDescribable.swift
//  ClickBye
//
//  Created by Yuriy Berdnikov on 3/17/17.
//  Copyright © 2017 Maxim. All rights reserved.
//

import UIKit

protocol ViewControllerDescribable: class {
    static var viewControllerId: String { get }
    static var navigationControllerId: String? { get }
    static var storyboardName: UIStoryboard.Name { get }
}

extension ViewControllerDescribable where Self: UIViewController {
    static var viewControllerId: String {
        return String(describing: self)
    }
    
    static var navigationControllerId: String? {
        return nil
    }
    
    static var storyboardName: UIStoryboard.Name {
        return .main
    }
}
