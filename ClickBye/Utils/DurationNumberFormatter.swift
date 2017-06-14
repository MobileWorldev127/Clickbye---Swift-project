//
//  DurationNumberFormatter.swift
//  ClickBye
//
//  Created by Yuriy Berdnikov on 4/24/17.
//  Copyright © 2017 Maxim. All rights reserved.
//

import UIKit
import Foundation

class DurationNumberFormatter: NumberFormatter {
    override func string(from number: NSNumber) -> String? {
        let durationMinutes = number.intValue
        
        var durationReadableText = ""
        
        let minutesInDay = 1440
        let minutesInHour = 60
        let days = durationMinutes / minutesInDay
        if days > 0 {
            durationReadableText = "\(days)d"
        }
        
        let hours = (durationMinutes - days * minutesInDay) / minutesInHour
        let minutes = durationMinutes - days * minutesInDay - hours * minutesInHour
        
        durationReadableText.append("\(hours)h\(minutes)m")
        
        return durationReadableText
    }
}
