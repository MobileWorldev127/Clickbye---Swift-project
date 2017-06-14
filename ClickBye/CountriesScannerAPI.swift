//
//  CountriesScannerAPI.swift
//  ClickBye
//
//  Created by Maxim  on 2/16/17.
//  Copyright © 2017 Maxim. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import JTMaterialSpinner
import GooglePlaces
import GoogleMaps

extension CountriesViewController {
    func suggestCountries() {
        
        guard let googlePlace = self.autosuggestPlace else {
            return
        }
        
        ClientAPI.shared.loadCountriesToFly(from: googlePlace.attributedPrimaryText.string, departDate: departDate, returnDate: returnDate, budget: "\(Int(budget))") { places, error in
            if let places = places {
                self.requestData = places.filter({ (place) -> Bool in
                    return (place.hotelPrice ?? 0) > 0 && (place.totalPrice() < Int(self.budget))
                })
                
                self.sortData()
                self.filterData()
            }
            
            self.tableView.reloadData()
            self.searchData = self.requestData
            self.spinnerView.endRefreshing()
        }
    }
}
