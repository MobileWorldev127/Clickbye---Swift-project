//
//  Airport.swift
//  ClickBye
//
//  Created by Yuriy Berdnikov on 3/23/17.
//  Copyright © 2017 Maxim. All rights reserved.
//

import Foundation
import ObjectMapper

class Airport: Mappable {
    var id: Int?
    var parentId: Int?
    var code: String?
    var type: String?
    var name: String?
    var cityName: String?
    
    required init?(map: Map){ }
    
    func mapping(map: Map) {
        id <- map["id"]
        code <- map["code"]
        name <- map["name"]
        cityName <- map["cityName"]
        parentId <- map["parentId"]
        type <- map["type"]
    }
}
