//
//  AlertController.swift
//  ClickBye
//
//  Created by marydort on 2/26/17.
//  Copyright © 2017 Perpetio. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController {
    class func alertWithTitle(title: String, message: String?) -> UIAlertController {
        let alertController = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction.init(title: "OK", style: .default, handler: nil);
        
        alertController.addAction(cancelAction)
        
        return alertController
    }
}
