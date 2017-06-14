//
//  ClientAPIRouter.swift
//  ClickBye
//
//  Created by Yuriy Berdnikov on 2/28/17.
//  Copyright © 2017 Maxim. All rights reserved.
//

import Foundation
import Alamofire

enum ClientAPIRouter : URLRequestConvertible {
    static let baseURL = URL(string: "http://beta.clickbye.com")!
    
    case logIn()
    case signUp()
    case sendRecoveryCode(String)
    case changePassword(String, String)
    case loadCitiesToFly(String, String, String, String, String)
    case loadCountriesToFly(String, String, String, String)
    case getAvailableFlights(String, String, String, String, PlaceBookingInfo)
    
    func asURLRequest() throws -> URLRequest {
        let result:(methodSting: String, path: String, parameters: Parameters) = {
            switch self {
            case .logIn():
                return ("GET", "/api/account", [:])
                
            case .signUp():
                return ("POST", "/api/account", [:])
                
            case .sendRecoveryCode(let login):
                return ("POST", "/api-public/accounts/\(login)/otp/send", [:])
                
            case .changePassword(let login, let newPassword):
                return ("POST", "/api-public/accounts/\(login)/\(newPassword)", [:])
                
            case .loadCountriesToFly(let from, let departureDate, let returnDate, let budget):
                let params: [String : Any] = [
                    "destinationCountryCode" : "anywhere",
                    "localeLanguage" : Locale.current.languageCode ?? "en",
                    "localeCountry" : Locale.current.regionCode ?? "US",
                    "flightSearchParameters" : [
                        "departureDate" : departureDate,
                        "returnDate" : returnDate,
                        "originalPlaces" : [from],
                        "filter" : [
                            "maxStops" : -1,
                            "budget" : budget
                        ],
                    ],
                    ]
                return ("POST", "/api/sky-scanner/load-cities-to-fly", params)
                
            case .loadCitiesToFly(let from, let country, let departureDate, let returnDate, let budget):
                let params: [String : Any] = [
                    "destinationCountryCode" : country,
                    "localeLanguage" : Locale.current.languageCode ?? "en",
                    "localeCountry" : Locale.current.regionCode ?? "US",
                    "flightSearchParameters" : [
                        "departureDate" : departureDate,
                        "returnDate" : returnDate,
                        "originalPlaces" : [from],
                        "filter" : [
                            "maxStops" : -1,
                            "budget" : budget
                        ],
                    ],
                    ]
                return ("POST", "/api/sky-scanner/load-cities-to-fly", params)
                
            case .getAvailableFlights(let from, let departureDate, let returnDate, let budget, let destination):
                let params: [String : Any] = [
                    "destinationPlaceCode" : destination.skyScannerCode ?? "",
                    "localeLanguage" : Locale.current.languageCode ?? "en",
                    "localeCountry" : Locale.current.regionCode ?? "US",
                    "flightSearchParameters" : [
                        "departureDate" : departureDate,
                        "returnDate" : returnDate,
                        "originalPlaces" : [from],
                        "filter" : [
                            "maxStops" : -1,
                            "budget" : budget
                        ],
                    ],
                    ]
                return ("POST", "/api/sky-scanner/available-flights-to-fly", params)
            }
        }()
        
        let url = try ClientAPIRouter.baseURL.asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(result.path))
        
        urlRequest.httpMethod = result.methodSting
        
        urlRequest.setValue(ClientAPI.shared.loginHeader, forHTTPHeaderField: AuthHeaderType.login.rawValue)
        urlRequest.setValue(ClientAPI.shared.accessTokenHeader, forHTTPHeaderField: AuthHeaderType.accessToken.rawValue)
        urlRequest.setValue(ClientAPI.shared.authTypeHeader, forHTTPHeaderField: AuthHeaderType.authType.rawValue)
        
        return try JSONEncoding.default.encode(urlRequest, with: result.parameters)
    }
}
