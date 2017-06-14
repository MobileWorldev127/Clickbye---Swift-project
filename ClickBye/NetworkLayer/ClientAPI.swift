//
//  ClientAPI.swift
//  ClickBye
//
//  Created by Yuriy Berdnikov on 2/28/17.
//  Copyright © 2017 Maxim. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper

enum AuthType: String {
    case facebook,
    email = "click-bye"
}

enum AuthHeaderType: String {
    case login = "click-bye-login",
    accessToken = "click-bye-access-token",
    authType = "click-bye-auth-type"
}

class ClientAPI {
    static let shared = ClientAPI()
    
    typealias OperationResultBlock = ((Bool, Error?) -> Void)

    var shouldUpdateFeed = true
    var tokenTypeHeader: String?
    var clientHeader: String?
    var UIDHeader: String?
    
    var loginHeader: String?
    var accessTokenHeader: String?
    var authTypeHeader: String?
    
    private init() {
        
    }
}

extension ClientAPI {
    // MARK: - Auth
    func logIn(email: String,
               password: String,
               completion: OperationResultBlock?) {
        guard let passwordBase64 = password.base64String() else {
            completion?(false, NSError.error(from: "Cannot create base64 string".localized))
            
            return
        }
        
        guard let secretEmail = DataCryptographer.encryptedString(message: email.lowercased()) else {
            completion?(false, NSError.error(from: "Email encryption failed".localized))
            
            return
        }
        
        let accessToken = "\(passwordBase64)_\(secretEmail)"
        loginHeader = email.lowercased()
        accessTokenHeader = accessToken
        authTypeHeader = AuthType.email.rawValue
        
        Alamofire.request(ClientAPIRouter.logIn()).responseJSON { response in
            // FIXME: Add code to handle error
            completion?(true, nil)
        }
    }
    
    func signUp(email: String,
                password: String,
                firstName: String,
                lastName: String,
                completion: OperationResultBlock?) {
        guard let passwordBase64 = password.base64String() else {
            completion?(false, NSError.error(from: "Cannot create base64 string".localized))
            
            return
        }

        guard let secretEmail = DataCryptographer.encryptedString(message: email.lowercased()) else {
            completion?(false, NSError.error(from: "Email encryption failed".localized))

            return
        }
        
        let accessToken = "\(passwordBase64)_\(secretEmail)"
        loginHeader = email.lowercased()
        accessTokenHeader = accessToken
        authTypeHeader = AuthType.email.rawValue
        
        Alamofire.request(ClientAPIRouter.signUp()).responseJSON { response in
            // FIXME: Add code to handle error
            completion?(true, nil)
        }
    }
    
    func signUpViaFacebook(email: String,
                           userIdentifier: String,
                           facebookAccessToken: String,
                           completion: OperationResultBlock?) {
        guard let userIdentifierBase64 = userIdentifier.base64String() else {
            completion?(false, NSError.error(from: "Cannot create base64 string".localized))
            
            return
        }
        
        let accessToken = "\(userIdentifierBase64)_\(facebookAccessToken)"
        loginHeader = email
        accessTokenHeader = accessToken
        authTypeHeader = AuthType.facebook.rawValue
        
        Alamofire.request(ClientAPIRouter.signUp()).responseJSON { response in
            // FIXME: Add code to handle error
            completion?(true, nil)
        }
    }
    
    func restorePassword(email: String, withCompletion completion:((_ errorMessage: Error?) -> ())?) {
        Alamofire.request(ClientAPIRouter.sendRecoveryCode(email)).response { (response) in
            completion?(response.error)
        }
    }
    
    func changePassword(email: String, newPassword: String, withCompletion completion:((_ error: Error?) -> ())?) {
        Alamofire.request(ClientAPIRouter.changePassword(email, newPassword)).response { (response) in
            completion?(response.error)
        }
    }
    
    func loadCountriesToFly(from: String, departDate: String, returnDate: String, budget: String, completion:@escaping (_ places: [PlaceBookingInfo]?, _ error: Error?) -> Void) {
        Alamofire.request(ClientAPIRouter.loadCountriesToFly(from, departDate, returnDate, budget)).responseArray { response in
            completion(response.result.value, response.result.error)
        }
    }
    
    func loadCitiesToFly(city: String, country: String, departDate: String, returnDate: String, budget: String, completion:@escaping (_ places: [PlaceBookingInfo]?, _ error: Error?) -> Void) {
        Alamofire.request(ClientAPIRouter.loadCitiesToFly(city, country, departDate, returnDate, budget)).responseArray { (response) in
            completion(response.result.value, response.result.error)
        }
    }
    
    func getAvailableFlights(from: String, departDate: String, returnDate: String, budget: String, deatination: PlaceBookingInfo, completion:@escaping (_ flights: [FlightRouteDetails]?, _ error: Error?) -> Void) {
        Alamofire.request(ClientAPIRouter.getAvailableFlights(from, departDate, returnDate, budget, deatination)).responseArray { (response) in
            completion(response.result.value, response.result.error)
        }
    }
}

