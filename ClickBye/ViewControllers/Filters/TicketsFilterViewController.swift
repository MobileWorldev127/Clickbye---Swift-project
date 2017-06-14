//
//  TicketsFilterViewController.swift
//  ClickBye
//
//  Created by Yuriy Berdnikov on 4/24/17.
//  Copyright © 2017 Maxim. All rights reserved.
//

import UIKit
import MaterialControls
import Localize_Swift
import TTRangeSlider
import SnapKit

class TicketsFilterViewController: UIViewController {
    
    static let storyboardID = "ticketsFilterViewController"
    static var ticketsFilterViewController: TicketsFilterViewController? {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: TicketsFilterViewController.storyboardID) as? TicketsFilterViewController
    }
    
    @IBOutlet var departureStackView: UIStackView!
    @IBOutlet var arrivalStackView: UIStackView!
    @IBOutlet var departureTimeSlider: TTRangeSlider!
    @IBOutlet var arrivalTimeSlider: TTRangeSlider!
    @IBOutlet var durationSlider: TTRangeSlider!
    @IBOutlet var airlinesStackView: UIStackView!
    
    @IBOutlet var stopButtons: [UIButton]!

    var flightData: [FlightRouteDetails]?
    var isDeparture = true
    var filterParams = FilterParams()
    
    var onApplyFilters: ((_ filterParams: FilterParams) -> Void)?
    
    fileprivate var departureButtons: [UIButton]?
    fileprivate var arrivalButtons: [UIButton]?
    fileprivate var airlineButtons: [UIButton]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureUI()
    }
}

extension TicketsFilterViewController {
    @IBAction func resetButtonPressed(_ sender: UIButton) {
        
        self.departureTimeSlider.selectedMinimum = self.departureTimeSlider.minValue
        self.departureTimeSlider.selectedMaximum = self.departureTimeSlider.maxValue
        
        self.arrivalTimeSlider.selectedMinimum = self.arrivalTimeSlider.minValue
        self.arrivalTimeSlider.selectedMaximum = self.arrivalTimeSlider.maxValue
        
        self.durationSlider.selectedMinimum = self.durationSlider.minValue
        self.durationSlider.selectedMaximum = self.durationSlider.maxValue
        
        _ = departureButtons?.map {$0.isSelected = false}
        departureButtons?.first?.isSelected = true
        
        _ = arrivalButtons?.map {$0.isSelected = false}
        arrivalButtons?.first?.isSelected = true
        
        _ = airlineButtons?.map {$0.isSelected = false}
        airlineButtons?.first?.isSelected = true
        
        _ = stopButtons?.map {$0.isSelected = false}

    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func applyButtonPressed(_ sender: UIButton) {
        self.filterParams.departureAirports = nil
        if self.departureButtons?.first?.isSelected == false {
            self.filterParams.departureAirports = self.departureButtons?.filter{$0.isSelected == true}.map{$0.title(for: .normal)?.stripSpacePrefix() ?? ""}
        }
        
        self.filterParams.arrivalAirports = nil
        if self.arrivalButtons?.first?.isSelected == false {
            self.filterParams.arrivalAirports = self.arrivalButtons?.filter{$0.isSelected == true}.map{$0.title(for: .normal)?.stripSpacePrefix() ?? ""}
        }
        
        self.filterParams.departureTime = (Int(self.departureTimeSlider.selectedMinimum), Int(self.departureTimeSlider.selectedMaximum))
        self.filterParams.arrivalTime = (Int(self.arrivalTimeSlider.selectedMinimum), Int(self.arrivalTimeSlider.selectedMaximum))
        self.filterParams.flightDuration = Int(self.durationSlider.selectedMaximum)
        
        self.filterParams.stops = self.stopButtons.filter{$0.isSelected == true}.map{FlighStops(rawValue: self.stopButtons.index(of: $0) ?? 0) ?? FlighStops.direct}
        
        self.filterParams.airlines = nil
        if self.airlineButtons?.first?.isSelected == false {
            self.filterParams.airlines = self.airlineButtons?.filter{$0.isSelected == true}.map{$0.title(for: .normal)?.stripSpacePrefix() ?? ""}
        }

        self.onApplyFilters?(self.filterParams)
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func stopsButtonPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    func departureAirportButtonPressed(_ sender: UIButton) {
        if sender == self.departureButtons?.first {
            _ = self.departureButtons?.map {$0.isSelected = false}
        } else if self.departureButtons?.first?.isSelected == true {
            self.departureButtons?.first?.isSelected = false
        }
        
        sender.isSelected = !sender.isSelected
    }
    
    func arrivalAirportButtonPressed(_ sender: UIButton) {
        if sender == self.arrivalButtons?.first {
            _ = self.arrivalButtons?.map {$0.isSelected = false}
        } else if self.arrivalButtons?.first?.isSelected == true {
            self.arrivalButtons?.first?.isSelected = false
        }
        
        sender.isSelected = !sender.isSelected
    }
    
    func airlineButtonPressed(_ sender: UIButton) {
        if sender == self.airlineButtons?.first {
            _ = self.airlineButtons?.map {$0.isSelected = false}
        } else if self.airlineButtons?.first?.isSelected == true {
            self.airlineButtons?.first?.isSelected = false
        }
        
        sender.isSelected = !sender.isSelected
    }
}

extension TicketsFilterViewController {
    func configureUI() {
        
        var departureAirports = ["All airports".localized()]
        
        if let airports = self.flightData?.map({ (flight) -> String in
            if self.isDeparture {
                return flight.from?.originStationPlace?.name ?? ""
            } else {
                return flight.to?.originStationPlace?.name ?? ""
            }
        }) {
            departureAirports.append(contentsOf: airports)
        }
        
        departureAirports = departureAirports.removeDuplicates()
        self.departureButtons = self.setupAirports(departureAirports, stackView: self.departureStackView, selector: #selector(TicketsFilterViewController.departureAirportButtonPressed(_:))) { button in
            if (self.filterParams.departureAirports == nil || self.filterParams.departureAirports?.isEmpty == true) &&
                departureAirports.first == button.title(for: .normal)?.stripSpacePrefix()
            {
                button.isSelected = true
            } else {
                button.isSelected = (self.filterParams.departureAirports?.contains(button.title(for: .normal)?.stripSpacePrefix() ?? "") == true)
            }
        }
        
        var arrivalAirports = ["All airports".localized()]
        if let airports = self.flightData?.map({ (flight) -> String in
            if self.isDeparture {
                return flight.to?.originStationPlace?.name ?? ""
            } else {
                return flight.from?.originStationPlace?.name ?? ""
            }
        }) {
            arrivalAirports.append(contentsOf: airports)
        }
        
        arrivalAirports = arrivalAirports.removeDuplicates()
        self.arrivalButtons = self.setupAirports(arrivalAirports, stackView: self.arrivalStackView, selector: #selector(TicketsFilterViewController.arrivalAirportButtonPressed(_:))) { button in
            if (self.filterParams.arrivalAirports == nil || self.filterParams.arrivalAirports?.isEmpty == true) &&
                arrivalAirports.first == button.title(for: .normal)?.stripSpacePrefix()
            {
                button.isSelected = true
            } else {
                button.isSelected = (self.filterParams.arrivalAirports?.contains(button.title(for: .normal)?.stripSpacePrefix() ?? "") == true)
            }
        }
        
        var airlines = ["All carriers".localized()]
        if let carrierNames = self.flightData?.map({ (flight) -> String in
            if self.isDeparture {
                return flight.from?.carrier?.name ?? ""
            } else {
                return flight.to?.carrier?.name ?? ""
            }
        }) {
            airlines.append(contentsOf: carrierNames)
        }
        
        airlines = airlines.removeDuplicates()
        self.airlineButtons = self.setupAirports(airlines, stackView: self.airlinesStackView, selector: #selector(TicketsFilterViewController.airlineButtonPressed(_:))) { button in
            if (self.filterParams.airlines == nil || self.filterParams.airlines?.isEmpty == true) &&
                airlines.first == button.title(for: .normal)?.stripSpacePrefix()
            {
                button.isSelected = true
            } else {
                button.isSelected = (self.filterParams.airlines?.contains(button.title(for: .normal)?.stripSpacePrefix() ?? "") == true)
            }
        }
        
        self.filterParams.stops?.forEach{ stop in
            self.stopButtons[stop.rawValue].isSelected = true
        }
        
        let flightSortedByDuration = self.flightData?.sorted(by: { (routeDetails1, routeDetails2) -> Bool in
            if self.isDeparture {
                return (routeDetails1.from?.duration ?? 0) > (routeDetails2.from?.duration ?? 0)
            } else {
                return (routeDetails1.to?.duration ?? 0) > (routeDetails2.to?.duration ?? 0)
            }
        })
        
        departureTimeSlider.tintColorBetweenHandles = UIColor.black
        departureTimeSlider.lineHeight = 2
        departureTimeSlider.minValue = 0
        departureTimeSlider.maxValue = 24
        departureTimeSlider.selectedMinimum = Float(self.filterParams.departureTime?.0 ?? 0)
        departureTimeSlider.selectedMaximum = Float(self.filterParams.departureTime?.1 ?? Int(departureTimeSlider.maxValue))
        
        arrivalTimeSlider.tintColorBetweenHandles = UIColor.black
        arrivalTimeSlider.lineHeight = 2
        arrivalTimeSlider.minValue = 0
        arrivalTimeSlider.maxValue = 24
        arrivalTimeSlider.selectedMinimum = Float(self.filterParams.arrivalTime?.0 ?? 0)
        arrivalTimeSlider.selectedMaximum = Float(self.filterParams.arrivalTime?.1 ?? Int(arrivalTimeSlider.maxValue))
        
        durationSlider.numberFormatterOverride = DurationNumberFormatter()
        if self.isDeparture {
            durationSlider.maxValue = Float(flightSortedByDuration?.first?.from?.duration ?? 0)
        } else {
            durationSlider.maxValue = Float(flightSortedByDuration?.first?.to?.duration ?? 0)
        }
        
        durationSlider.selectedMaximum = Float(self.filterParams.flightDuration ?? Int(durationSlider.maxValue))
        durationSlider.tintColorBetweenHandles = UIColor.black
        durationSlider.lineHeight = 2
    }
    
    func setupAirports(_ airports: [String], stackView: UIStackView, selector: Selector, configBlock: ((_ button: UIButton) -> Void)?) -> [UIButton] {
        var buttons = [UIButton]()
        
        airports.forEach { airport in
            let button = UIButton()
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.setTitle("  \(airport)", for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.setImage(UIImage(named: "checkbox-blank"), for: .normal)
            button.setImage(UIImage(named: "checkbox-marked"), for: .selected)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: selector, for: .touchUpInside)
            button.snp.makeConstraints { make in
                make.height.equalTo(30)
            }
            
            configBlock?(button)
            
            buttons.append(button)
            stackView.addArrangedSubview(button)
        }
        
        return buttons
    }
}

