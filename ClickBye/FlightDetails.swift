//
//  FlightDetails.swift
//  ClickBye
//
//  Created by Yuriy Berdnikov on 3/23/17.
//  Copyright © 2017 Maxim. All rights reserved.
//

import Foundation
import ObjectMapper

class FlightDetails: Mappable {
    var id: String?
    var segmentIds: [Int]?
    var departureDate: Date?
    var arrivalDate: Date?
    var duration: Int?
    var durationReadableText: String? {
        get {
            guard let durationMinutes = duration else {
                return nil
            }
            
            var durationReadableText = ""
            
            let minutesInDay = 1440
            let minutesInHour = 60
            let days = durationMinutes / minutesInDay
            if days > 0 {
                durationReadableText = "\(days)\("d".localized())"
            }
            
            let hours = (durationMinutes - days * minutesInDay) / minutesInHour
            let minutes = durationMinutes - days * minutesInDay - hours * minutesInHour
            
            durationReadableText.append("\(hours)\("h".localized())\(minutes)\("m".localized())")
            
            return durationReadableText
        }
    }
    
    var stops: [Int]?
    var carrier: FlightCarrier?
    
    var originStationPlace: Airport?
    var destinationStationPlace: Airport?
    
    required init?(map: Map){ }
    
    func mapping(map: Map) {
        
        id <- map["id"]
        segmentIds <- map["segmentIds"]
        
        departureDate <- (map["departure"], CustomDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss"))
        arrivalDate <- (map["arrival"], CustomDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss"))
        
        duration <- map["duration"]
        stops <- map["stops"]
        carrier <- map["carrier"]
        originStationPlace <- map["originStationPlace"]
        destinationStationPlace <- map["destinationStationPlace"]
    }
}

extension FlightDetails: Hashable, Equatable {
    var hashValue: Int { get { return id?.hashValue ?? 0 } }
}

func ==(left:FlightDetails, right:FlightDetails) -> Bool {
    return left.id == right.id
}
