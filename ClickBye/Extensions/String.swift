//
//  String.swift
//  ClickBye
//
//  Created by Yuriy Berdnikov on 3/16/17.
//  Copyright © 2017 Maxim. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func isEmail() -> Bool {
        let regex = try? NSRegularExpression(pattern: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$", options: [.caseInsensitive])
        
        return regex?.firstMatch(in: self, options:[], range: NSMakeRange(0, utf16.count)) != nil
    }
    
    func base64String() -> String? {
        let data = self.data(using: .utf8)
        
        return data?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
    }
    
    func stripSpacePrefix() -> String {
        var tmpStr = self
        while tmpStr.hasPrefix(" ") {
            tmpStr.remove(at: self.startIndex)
        }
        
        return tmpStr
    }
    
    func dropLast(_ n: Int = 1) -> String {
        return String(characters.dropLast(n))
    }
    var dropLast: String {
        return dropLast()
    }
    
    func dropFirst(_ n: Int = 1) -> String {
        return String(characters.dropFirst(n))
    }
    var dropFirs: String {
        return dropFirst()
    }
    
    func lowercaseFirstLetter() -> String {
        let first = String(characters.prefix(1)).lowercased()
        let other = String(characters.dropFirst())
        return first + other
    }
    
    mutating func lowercaseFirstLetter() {
        self = self.lowercaseFirstLetter()
    }
}
