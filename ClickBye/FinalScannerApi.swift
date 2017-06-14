//
//  FinalScannerApi.swift
//  ClickBye
//
//  Created by Maxim  on 2/20/17.
//  Copyright © 2017 Maxim. All rights reserved.
//


import UIKit
import Alamofire
import SwiftyJSON

extension FinalViewController {
    
    func getAvailableFlights() {
        
        guard let place = selectedPlace else {
            self.finalViewInfo()
            self.spinnerView.endRefreshing()
            self.tableView.reloadData()
            
            return
        }
        
        ClientAPI.shared.getAvailableFlights(from: departPlace?.attributedPrimaryText.string ?? "", departDate: self.departDates ?? "", returnDate: self.returnDates ?? "", budget: "\(Int(self.budget))", deatination: place) {[weak self] flights, error in
            
            self?.flightRoutes = flights
            self?.finalViewInfo()
            self?.spinnerView.endRefreshing()
            self?.tableView.reloadData()
        }
    }
}

