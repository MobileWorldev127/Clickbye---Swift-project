//
//  NSError.swift
//  ClickBye
//
//  Created by Yuriy Berdnikov on 3/20/17.
//  Copyright © 2017 Maxim. All rights reserved.
//

import Foundation

extension NSError {
    static func error(from message: String) -> NSError {
        return NSError(domain: String(), code: 0, userInfo: [NSLocalizedDescriptionKey : message])
    }
}
