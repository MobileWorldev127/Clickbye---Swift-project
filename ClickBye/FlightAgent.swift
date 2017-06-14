//
//  FlightAgent.swift
//  ClickBye
//
//  Created by Yuriy Berdnikov on 3/23/17.
//  Copyright © 2017 Maxim. All rights reserved.
//

import Foundation
import ObjectMapper

class FlightAgent: Mappable {    
    var id: Int?
    var name: String?
    var imageUrl: String?
    var bookingNumber: String?
    var price: Float?
    var deepLink: String?
    
    required init?(map: Map){ }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        imageUrl <- map["imageUrl"]
        bookingNumber <- map["bookingNumber"]
        price <- map["price"]
        deepLink <- map["deepLink"]
    }
}
