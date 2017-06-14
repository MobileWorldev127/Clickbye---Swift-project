//
//  CityScannerApi.swift
//  ClickBye
//
//  Created by Maxim  on 2/17/17.
//  Copyright © 2017 Maxim. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

extension CityViewController {
    
    func getSuggest() {
        guard let place = self.selectedPlace else {
            return
        }
        
        ClientAPI.shared.loadCitiesToFly(city: departPlace?.attributedPrimaryText.string ?? "", country: place.countryCode ?? "", departDate: self.departDate ?? "", returnDate: self.returnDate ?? "", budget: "\(Int(self.budget))") { places, error in
            if let places = places {
                self.cityData = places
            }
            
            self.tableView.reloadData()
            self.spinnerView.endRefreshing()
        }
    }
}

    

