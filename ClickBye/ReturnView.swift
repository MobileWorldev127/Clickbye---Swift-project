//
//  ReturnView.swift
//  ClickBye
//
//  Created by Maxim  on 11/14/16.
//  Copyright © 2016 Maxim. All rights reserved.
//

import UIKit
import MaterialControls

protocol AcceptReturnDates {
    func acceptDataReturn(_ data: Dates)
}

class ReturnView: UIViewController, MDCalendarDelegate {
    
    var dateСhosen: (()->())?
    var delegate: AcceptReturnDates?
    var rDay = String()
    var rMonth = String()
    var rWeek = String()
    var date: Date?
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarView.calendar.minimumDate = Date()
        
        calendarView.header.backgroundColor = Theme.Colors.brightRed
        calendarView.header.labelDayName.backgroundColor = Theme.Colors.brightRed
        calendarView.header.labelMonthName.backgroundColor = Theme.Colors.brightRed
        calendarView.header.labelDate.backgroundColor = Theme.Colors.brightRed
        calendarView.header.labelYear.backgroundColor = Theme.Colors.brightRed
        
        calendarView.header.headerBackgroundColor = Theme.Colors.brightRed
        calendarView.calendar.titleColors[MDCalendarCellState.today.rawValue] = Theme.Colors.brightRed
        calendarView.calendar.backgroundColors[MDCalendarCellState.selected.rawValue] = Theme.Colors.brightRed
        calendarView.calendar.firstWeekday = 2
        
        calendarView.calendar.reloadData()
        
        if let date = date {
            calendarView.calendar.selectedDate = date
        }

        showAnimate()
    }
    
    //MARK: Actions
    @IBOutlet var calendarView: MDDatePicker! {
        didSet {
            calendarView.delegate = self
        }
    }
    
    @IBAction func approveReturn(_ sender: UIButton) {
        removeAnimate()
    }
    
    @IBAction func cancelReturn(_ sender: UIButton) {
        removeAnimate()
    }
    
    //MARK: MDCalendarDelegate
    open func calendar(_ calendar: MDCalendar, didSelect date: Date?) {
        let today = date
        
        //Date For API
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let apiDate: String = dateFormatter.string(from: today!)
        
        //Date for week day
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "EEE"
        let weekDay: NSString = dateFormatter1.string(from: today!) as NSString
        
        //Date for week number
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "dd"
        let weekNumber: NSString = dateFormatter2.string(from: today!) as NSString
        
        //Date for month name
        let dateFormatter3 = DateFormatter()
        dateFormatter3.dateFormat = "MMM"
        let monthName: NSString = dateFormatter3.string(from: today!) as NSString
        
        rDay = weekNumber as String
        rMonth = monthName as String
        rWeek = weekDay as String
        
        let datesToSend = Dates(day: rDay, weekday: rWeek, month: rMonth, fullDate: apiDate)
        self.delegate?.acceptDataReturn(datesToSend)
    }
    
    //MARK: Helpers
    func showAnimate() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.view.transform =  CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform =   CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    func removeAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
            }, completion: {(finished : Bool) in
                if (finished) {
                    self.view.removeFromSuperview()
                    self.dateСhosen?()
                }
        })
    }
}
