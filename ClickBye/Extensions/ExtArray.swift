//
//  ExtArray.swift
//  ClickBye
//
//  Created by Yuriy Berdnikov on 4/21/17.
//  Copyright © 2017 Maxim. All rights reserved.
//

import Foundation

extension Array where Element:Equatable {
    func removeDuplicates() -> [Element] {
        var result = [Element]()
        
        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        
        return result
    }
}
