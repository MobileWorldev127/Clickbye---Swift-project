//
//  ChoseFlyModel.swift
//  ClickBye
//
//  Created by Maxim  on 12/16/16.
//  Copyright © 2016 Maxim. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps

extension ChoseFlyView {
    
    func getDatesForlabels(defaultDepart: Date = Date() + 3.days, defaultReturn: Date = Calendar.current.date(byAdding: .day, value: 10, to: Date())!) {
        let dateFormatter = DateFormatter()
        let dateFormatter1 = DateFormatter()
        let dateFormatter2 = DateFormatter()
        let dateFormatter3 = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        self.defaultDepartDate = dateFormatter.string(from: defaultDepart)
        
        self.defaultReturnDate = dateFormatter.string(from: defaultReturn)

        dateFormatter1.dateFormat = "dd"
        self.defaultDepartDay = dateFormatter1.string(from: defaultDepart) as String
        
        dateFormatter2.dateFormat = "EEE"
        self.defaultDepartWeekDay = dateFormatter2.string(from: defaultDepart) as String
        
        dateFormatter3.dateFormat = "MMM"
        self.defaultDepartMonth = dateFormatter3.string(from: defaultDepart) as String
        
        self.departDay.text = self.defaultDepartDay
        self.departWeekday.text = self.defaultDepartWeekDay?.uppercased()
        self.departMonth.text = self.defaultDepartMonth?.uppercased()
        
        self.defaultReturnDay = dateFormatter1.string(from: defaultReturn) as String
        self.defaultReturnWeekDay = dateFormatter2.string(from: defaultReturn) as String
        self.defaultReturnMonth = dateFormatter3.string(from: defaultReturn) as String
        
        self.returnDay.text = self.defaultReturnDay
        self.returnWeekday.text = self.defaultReturnWeekDay?.uppercased()
        self.returnMonth.text = self.defaultReturnMonth?.uppercased()
    }
    
    func verifySelectedDates() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let today = Date() + 3.days
        
        var departDate = today
        if self.departDate.isEmpty {
            departDate = dateFormatter.date(from: self.defaultDepartDate) ?? today
        } else {
            departDate = dateFormatter.date(from: self.departDate) ?? today
        }

        var returnDate = today
        if self.returnDate.isEmpty {
            returnDate = departDate + 7.days
        } else {
            returnDate = dateFormatter.date(from: self.returnDate) ?? today
        }

        if returnDate <= departDate {
            returnDate = departDate + 7.days
        }
        
        if departDate < today {
            getDatesForlabels(defaultDepart: today, defaultReturn: returnDate)
        }

        getDatesForlabels(defaultDepart: departDate, defaultReturn: returnDate)
    }
    
    func verifySelectedReturnDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let today = Date() + 3.days
        
        var departDate = today
        if self.departDate.isEmpty {
            departDate = dateFormatter.date(from: self.defaultDepartDate) ?? today
        } else {
            departDate = dateFormatter.date(from: self.departDate) ?? today
        }
        
        var returnDate = today
        if self.returnDate.isEmpty  {
            returnDate = dateFormatter.date(from: self.defaultReturnDate) ?? today
        } else {
            returnDate = dateFormatter.date(from: self.returnDate) ?? today
        }
        
        if departDate < today {
            getDatesForlabels(defaultDepart: today, defaultReturn: returnDate)
        }
        
        getDatesForlabels(defaultDepart: departDate, defaultReturn: returnDate)
    }
    
    func sendDataAndMoveToCountries() {
        let cvc = storyboard?.instantiateViewController(withIdentifier: "countries") as! CountriesViewController
        
        if (departDate.characters.count <= 0) {
            cvc.departDate = self.defaultDepartDate
        } else {
            cvc.departDate = departDate
        }
        
        if (returnDate.characters.count <= 0) {
            cvc.returnDate = self.defaultReturnDate
        } else {
            cvc.returnDate = returnDate
        }
        
        cvc.autosuggestPlace = selectedGooglePlace
        
        if let budget = self.budgtetTextField?.text {
            cvc.budget = Float(budget.replacingOccurrences(of: " " , with: "")) ?? 0
        }
        
        navigationController?.navigationBar.barTintColor = Theme.Colors.brightRed
        navigationController?.navigationBar.tintColor = UIColor.flatWhite
        navigationController?.pushViewController(cvc, animated: true)
    }
    
    func clear() {
        view.backgroundColor = .white
        edgesForExtendedLayout = []
        tableview.delegate = self
        tableview.dataSource = self
        tableview.isHidden = true
        tableview.separatorStyle = .none
        
        // Set up the autocomplete filter.
        let filter = GMSAutocompleteFilter()
        filter.type = .establishment
        
        // Create the fetcher.
        fetcher = GMSAutocompleteFetcher()
        fetcher?.delegate = self
        
        textField?.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
    }
    
    func textFieldDidChange(textField: UITextField) {
        if (textField.text?.characters.count)! <= 7 {
            tableview.isHidden = false
            fetcher?.sourceTextHasChanged(textField.text!)
            searchResults.removeAll()
        }
        //Hides TVC when text field isEmpty!
        if (textField.text?.characters.count)! == 0 {
            tableview.isHidden = true
        }
    }
    
    func attributedText() {
        let yourAttributes : [String: Any] = [
            NSFontAttributeName : UIFont.systemFont(ofSize: 14),
            NSForegroundColorAttributeName : UIColor.white,
            NSUnderlineStyleAttributeName : NSUnderlineStyle.styleSingle.rawValue]
        
        let attributeString = NSMutableAttributedString(string: "Advanced Search".localized(),
                                                        attributes: yourAttributes)
        advancedSearch.setAttributedTitle(attributeString, for: .normal)
        textField.layer.cornerRadius = 8.0
    }
    
    func addDepartGesture() {
        departGesture.isUserInteractionEnabled = true
        let dSelector = #selector(ChoseFlyView.presentDepart)
        let tapGesture = UITapGestureRecognizer(target: self, action: dSelector)
        tapGesture.numberOfTapsRequired = 1
        departGesture.addGestureRecognizer(tapGesture)
    }
    
    func addReturnGesture() {
        returnGesture.isUserInteractionEnabled = true
        let dSelector = #selector(ChoseFlyView.presentReturn)
        let tapGesture = UITapGestureRecognizer(target: self, action: dSelector)
        tapGesture.numberOfTapsRequired = 1
        returnGesture.addGestureRecognizer(tapGesture)
    }
    
    func presentDepart() {
        self.view.endEditing(true)
        
        let popOverVC = UIStoryboard(name: "Main", bundle:
            nil).instantiateViewController(withIdentifier: "presentDepart") as! DepartView
        
        if !self.departDate.isEmpty {
            popOverVC.date = Date.dateFromString(dateString: self.departDate, format: "yyyy-MM-dd")
        } else {
            popOverVC.date = Date.dateFromString(dateString: self.defaultDepartDate, format: "yyyy-MM-dd")
        }
        
        popOverVC.delegate = self
        popOverVC.dateСhosen = {
            if self.isDepartReturnDateCorrect() == false {
                self.showAlertControllerWithTitle(title: "Error".localized(), message: "Depart date must be less then return date.".localized())
            }
        }
        self.addChildViewController(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
    }
    
    func presentReturn() {
        self.view.endEditing(true)
        
        let popOverVC = UIStoryboard(name: "Main", bundle:
            nil).instantiateViewController(withIdentifier: "presentReturn") as! ReturnView
        
        if !self.returnDate.isEmpty {
            popOverVC.date = Date.dateFromString(dateString: self.returnDate, format: "yyyy-MM-dd")
        } else {
            popOverVC.date = Date.dateFromString(dateString: self.defaultReturnDate, format: "yyyy-MM-dd")
        }
        
        popOverVC.delegate = self
        popOverVC.dateСhosen = {
            if self.isDepartReturnDateCorrect() == false {
                self.showAlertControllerWithTitle(title: "Error".localized(), message: "Return date must be after depart date.".localized())
            }
        }
        self.addChildViewController(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
    }
    
    func presentAdvanced() {
        let popOverVC = UIStoryboard(name: "Main", bundle:
            nil).instantiateViewController(withIdentifier: "advancedSearchVC") as! AdvancedSearchView
        
        self.addChildViewController(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
    }
    
    func isDepartReturnDateCorrect() -> Bool {
        let dateFormat = "yyyy-MM-dd"
        let departDate = self.departDate.isEmpty ? Date.dateFromString(dateString: self.defaultDepartDate, format: dateFormat) : Date.dateFromString(dateString: self.departDate, format: dateFormat)
        let returnDate = self.returnDate.isEmpty ? Date.dateFromString(dateString: self.defaultReturnDate, format: dateFormat) : Date.dateFromString(dateString: self.returnDate, format: dateFormat)
        
        return departDate <= returnDate
    }
}
