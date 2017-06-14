//
//  ChoseFlyView.swift
//  ClickBye
//
//  Created by Maxim  on 11/14/16.
//  Copyright © 2016 Maxim. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MaterialControls
import GooglePlaces
import GoogleMaps
import ChameleonFramework
import SideMenu
import Analytics

class ChoseFlyView: UIViewController, GMSAutocompleteFetcherDelegate, AcceptDepartDates, AcceptReturnDates, UITextFieldDelegate  {
    //Default dates for labels
    var defaultDepartDay: String?
    var defaultDepartWeekDay: String?
    var defaultDepartMonth: String?
    var defaultReturnDay: String?
    var defaultReturnWeekDay: String?
    var defaultReturnMonth: String?
    
    
    var defaultReturnDate = ""
    var defaultDepartDate = ""
    
    var returnDate = ""
    var departDate = ""
    var selectedCell = String()
    var searchResults = [String]()
    var fetcher: GMSAutocompleteFetcher?
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var advancedSearch: UIButton!
    @IBOutlet weak var departGesture: UIView!
    @IBOutlet weak var returnGesture: UIView!
    @IBOutlet weak var budgetGesture: UIView!
    @IBOutlet weak var departWeekday: UILabel!
    @IBOutlet weak var departDay: UILabel!
    @IBOutlet weak var departMonth: UILabel!
    @IBOutlet weak var returnWeekday: UILabel!
    @IBOutlet weak var returnDay: UILabel!
    @IBOutlet weak var returnMonth: UILabel!
    @IBOutlet weak var inspireBtn: UIButton!
    @IBOutlet weak var budgtetTextField: UITextField!
    
    fileprivate var googlePlaces: [GMSAutocompletePrediction]?
    internal var selectedGooglePlace: GMSAutocompletePrediction?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        addDepartGesture()
        addReturnGesture()
        attributedText()
        clear()
        getDatesForlabels()
        textField.delegate = self
        budgtetTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    
    @IBAction func inspireBtn(_ sender: UIButton) {
        
        SEGAnalytics.shared().track("Home_InspireMe_Clicked", properties: ["DepartureDate" : self.departDate,
                                                                           "ReturnDate" : self.returnDate,
                                                                           "OriginCity" : self.selectedGooglePlace?.attributedSecondaryText?.string ?? ""])
        
        sendDataAndMoveToCountries()
    }
    
    @IBAction func advancedSearchBtn(_ sender: UIButton) {
        presentAdvanced()
    }
    
    @IBAction func menuButtonPressed(_ sender: UIButton) {
        if let menuLeftNavigationController = storyboard?.instantiateViewController(withIdentifier: "SideMenuNavigationController") as? UISideMenuNavigationController {
            menuLeftNavigationController.isNavigationBarHidden = true
            
            SideMenuManager.menuLeftNavigationController = menuLeftNavigationController
            
            self.present(menuLeftNavigationController, animated: true, completion: nil)
        }
    }
    
    func acceptData(_ data: Dates) {
        self.departDay.text = data.day
        self.departWeekday.text = data.weekday.uppercased()
        self.departMonth.text = data.month.uppercased()
        self.departDate = data.fullDate
        
        verifySelectedDates()
    }
    
    func acceptDataReturn(_ data: Dates) {
        self.returnDay.text = data.day
        self.returnWeekday.text = data.weekday.uppercased()
        self.returnMonth.text = data.month.uppercased()
        self.returnDate = data.fullDate
        
        verifySelectedReturnDate()
    }
    
    
    func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
        for prediction in predictions {
            self.searchResults.append(prediction.attributedFullText.string)
        }
        
        googlePlaces = predictions
        self.tableview.reloadData()
    }
    
    func didFailAutocompleteWithError(_ error: Error) {
        textField?.text = error.localizedDescription
    }
}

extension ChoseFlyView: ViewControllerDescribable {
    // MARK: - ViewControllerDescribable
    static var navigationControllerId: String? {
        return "ChoseFlyNavigationController"
    }
}

extension ChoseFlyView : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = self.searchResults[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableview.isHidden = true
        
        self.view.endEditing(true)
        
        if let googlePlace = googlePlaces?[indexPath.row] {
            textField?.text = googlePlace.attributedFullText.string
            
            selectedGooglePlace = googlePlace
        }
    }
}

extension ChoseFlyView {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.budgtetTextField {
            if let budgetText = self.budgtetTextField.text,
                let budget = Int(budgetText.replacingOccurrences(of: " ", with: ""))
            {
                if budget < Constants.Budget.minBudget {
                    self.budgtetTextField.text = "\(Constants.Budget.minBudget)"
                    MDToast(text: "Minimum budget".localized(), duration: 2).show()
                } else if budget > Constants.Budget.maxBudget {
                    self.budgtetTextField.text = "\(Constants.Budget.maxBudget)"
                    MDToast(text: "Maximum budget".localized(), duration: 2).show()
                }
            }
        }
    }
    
    @IBAction func budgetFieldTextChanged(_ sender: UITextField) {
        if let budgetText = self.budgtetTextField.text,
            let budget = Int(budgetText.replacingOccurrences(of: " ", with: ""))
        {
            if budget > Constants.Budget.maxBudget {
                self.budgtetTextField.text = "\(Constants.Budget.maxBudget)"
            }
        }
        
        self.budgtetTextField.text = self.budgtetTextField.text?.replacingOccurrences(of: " ", with: "")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.budgtetTextField {
            if let charactersCount = textField.text?.characters.count, charactersCount >= Constants.Budget.maxBudgetLength && !string.isEmpty {
                return false
            }
            let aSet = NSCharacterSet(charactersIn:"0123456789 ").inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            
            return string == numberFiltered
        }
        
        return true
    }
}
