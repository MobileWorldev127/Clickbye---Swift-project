//
//  FilterParams.swift
//  ClickBye
//
//  Created by Yuriy Berdnikov on 4/21/17.
//  Copyright © 2017 Maxim. All rights reserved.
//

import Foundation
import UIKit

enum Regions: Int {
    case all,
    europe,
    americas,
    asia,
    oceania,
    africa
    
    var title: String {
        switch self {
        case .all:
            return "All".localized()
        case .europe:
            return "Europe".localized()
        case .americas:
            return "Americas".localized()
        case .asia:
            return "Asia".localized()
        case .oceania:
            return "Oceania".localized()
        case .africa:
            return "Africa".localized()
        }
    }
}

enum FlighStops: Int {
    case direct,
    oneStop,
    moreThanTwoStops
    
    var title: String {
        switch self {
        case .direct:
            return "Direct".localized()
        case .oneStop:
            return "1 Stop".localized()
        case .moreThanTwoStops:
            return "2+ Stops".localized()
        }
    }
}

class FilterParams {
    var regions: [Regions]?
    var flightCost: (Int, Int)?
    var themes: [String]?
    
    var departureAirports: [String]?
    var arrivalAirports: [String]?
    var departureTime: (Int, Int)?
    var arrivalTime: (Int, Int)?
    var flightDuration: Int?
    var stops: [FlighStops]?
    var airlines: [String]?
    
    init() {
        regions = [.all]
        departureTime = (0, 24)
        arrivalTime = (0, 24)
    }
}
