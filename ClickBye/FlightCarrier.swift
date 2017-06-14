//
//  FlightCarrier.swift
//  ClickBye
//
//  Created by Yuriy Berdnikov on 3/23/17.
//  Copyright © 2017 Maxim. All rights reserved.
//

import Foundation
import ObjectMapper

class FlightCarrier: Mappable {
    var id: String?
    var code: Int?
    var imageUrl: String?
    var name: String?
    var displayCode: Float?
    var firstCapitalName: String?
    
    required init?(map: Map){ }
    
    func mapping(map: Map) {
        id <- map["id"]
        code <- map["code"]
        imageUrl <- map["imageUrl"]
        name <- map["name"]
        displayCode <- map["displayCode"]
        firstCapitalName <- map["firstCapitalName"]
    }
}
