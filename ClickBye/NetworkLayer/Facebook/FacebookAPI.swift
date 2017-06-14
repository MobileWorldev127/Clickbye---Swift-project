//
//  FacebookAPI.swift
//  ClickBye
//
//  Created by Yuriy Berdnikov on 3/17/17.
//  Copyright © 2017 Maxim. All rights reserved.
//

import Foundation
import FBSDKLoginKit

final class FacebookAPI {
    static let shared = FacebookAPI()
    
    typealias LogInResultBlock = ((FBSDKLoginManagerLoginResult?) -> Void)
    typealias UserProfileResultBlock = ((User?, Error?) -> Void)
    
    private init() {
        
    }
}

extension FacebookAPI {
    // MARK: - Authentification
    func logIn(readPermissions: [String] = ["email"],
               from viewController: UIViewController?,
               completion: LogInResultBlock?) {
        let loginManager = FBSDKLoginManager()
        
        loginManager.logIn(withReadPermissions: readPermissions, from: viewController) { loginResult, error in
            completion?(loginResult)
        }
    }
}

extension FacebookAPI {
    // MARK: - Fetch Profile
    func fetchUserProfile(parameters: Dictionary<String, String> = ["fields": "email, name, last_name, first_name, age_range, link, gender, locale, timezone"],
                          completion: UserProfileResultBlock?) {
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).start { connection, result, error in
            guard let result = result as? NSDictionary,
                error == nil else {
                completion?(nil, error)

                return
            }
            
            let userProfile = User(result)
            
            completion?(userProfile, nil)
        }
    }
}
