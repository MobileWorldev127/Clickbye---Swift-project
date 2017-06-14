//
//  User.swift
//  ClickBye
//
//  Created by Yuriy Berdnikov on 3/2/17.
//  Copyright © 2017 Maxim. All rights reserved.
//

import UIKit

struct User {
    var userIdentifier: String?
    var name: String?
    var profileImage: UIImage?
    var location: String?
    var email: String?
    
    var analyticsTraits: [String: Any]? {
        guard let facebookProfile = self.facebookProfile else {
            return nil
        }
        
        var traits = [String: Any]()
        facebookProfile.allKeys.forEach { key in
            if let key = key as? NSString {
                traits[key.replacingOccurrences(of: "_", with: " ").capitalized.replacingOccurrences(of: " ", with: "").lowercaseFirstLetter()] = facebookProfile.value(forKey: key as String)
            }
        }
        
        traits["RegType"] = "facebook"
        
        return traits
    }
    
    private var facebookProfile: NSDictionary?
    
    static var currentUser: User?
    
    init() {
        
    }
    
    init(_ facebookProfile: NSDictionary) {
        self.facebookProfile = facebookProfile
        self.userIdentifier = facebookProfile["id"] as? String
        self.name = facebookProfile["name"] as? String
        self.email = facebookProfile["email"] as? String
    }
}
