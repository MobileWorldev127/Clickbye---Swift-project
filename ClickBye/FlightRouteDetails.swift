//
//  FlightRouteDetails.swift
//  ClickBye
//
//  Created by Yuriy Berdnikov on 3/23/17.
//  Copyright © 2017 Maxim. All rights reserved.
//

import Foundation
import ObjectMapper

class FlightRouteDetails: Mappable {

    var from: FlightDetails?
    var to: FlightDetails?
    var agents: [FlightAgent]?

    required init?(map: Map){ }
    
    func mapping(map: Map) {
        
        from <- map["outbound"]
        to <- map["inbound"]
        agents <- map["agents"]
    }
}
