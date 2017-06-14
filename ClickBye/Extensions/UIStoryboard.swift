//
//  UIStoryboard.swift
//  ClickBye
//
//  Created by Yuriy Berdnikov on 3/17/17.
//  Copyright © 2017 Maxim. All rights reserved.
//

import UIKit

extension UIStoryboard {
    enum Name: String {
        case main = "Main",
        launchScreen = "LaunchScreen",
        auth = "Auth"
    }
    
    class func initialized(with name: Name) -> UIStoryboard {
        return UIStoryboard(name: name.rawValue, bundle: nil)
    }
}

