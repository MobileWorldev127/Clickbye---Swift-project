//
//  Constants.swift
//  ClickBye
//
//  Created by Maxim  on 2/16/17.
//  Copyright © 2017 Maxim. All rights reserved.
//

import Foundation

let delimiter = ","


struct Constants {
    struct Flickr {
        static let userID = "Clickbye"
        static let apiKey = "da0402b830d8dfdf0e8b1abcfa2d897a"
        static let clientSecret = "72ffdc1767db22ba"
    }
    
    struct GooglePlaces {
        static let poiAPIKey = "AIzaSyA2irR8i9urAC4J1gy_iNb5KwWeqtGbJWY"
    }
    
    struct URLs {
        static let policyURL = "http://www.clickbye.com/PrivacyPolicy.htm"
        static let termsURL = "http://www.clickbye.com/Terms.htm"
    }
    
    struct Keychain {
        static let appServiceID = "com.clickbye.ios"
    }
    
    struct Segment {
        static let writeKey = "CIdLkVd0OG9YTnfdfmRZFm2p4YQQ5Qel"
    }
    
    struct Forecast {
        static let apiKey = "62aa6776608a07843f9c2a3b10d58120"
    }
    
    struct Budget {
        static let minBudget = 50
        static let maxBudget = 20000
        static let defaultBudget = 200
        static let maxBudgetLength = 5
    }
    
    enum Theme: String {
        case art = "Art",
        beach = "Beach",
        family = "Family",
        party = "Party",
        sports = "Sports"
        
        static func defaultThemes() -> [Theme] {
            return [.art, .beach, .family, .party, .sports]
        }
    }
}
