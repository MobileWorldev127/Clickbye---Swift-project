//
//  PlaceBookingInfo.swift
//  ClickBye
//
//  Created by Yuriy Berdnikov on 3/22/17.
//  Copyright © 2017 Maxim. All rights reserved.
//

import Foundation
import ObjectMapper

class PlaceBookingInfo: Mappable {
    
    var name: String?
    var minPrice: Int?
    var skyScannerCode: String?
    var countryName: String?
    var countryCode: String?
    var imgUrl: String?
    var hotelPrice: Int?
    var priceEuro: String?
    var price: Int = 0
    var shouldLoadMore = true
    var themes: [String]?
    
    required init?(map: Map){ }
    
    func mapping(map: Map) {
        name <- map["name"]
        minPrice <- map["minPrice"]
        skyScannerCode <- map["skyScannerCode"]
        countryName <- map["countryName"]
        countryCode <- map["countryCode"]
        imgUrl <- map["imgUrl"]
        hotelPrice <- map["hotelPrice"]
        price <- map["price"]
        priceEuro <- map["priceEuro"]
        themes <- map["themes"]
    }
    

    func totalPrice() -> Int {
        return (self.hotelPrice ?? 0) + self.price
    }
}

func ==(left:PlaceBookingInfo, right:PlaceBookingInfo) -> Bool {
    return left.name == right.name && left.skyScannerCode == right.skyScannerCode &&
        left.countryName == right.countryName && left.countryCode == right.countryCode
}
