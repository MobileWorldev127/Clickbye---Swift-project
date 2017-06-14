//
//  CountriesViewController.swift
//  ClickBye
//
//  Created by Maxim  on 2/16/17.
//  Copyright © 2017 Maxim. All rights reserved.
//

import UIKit
import DropDown
import JTMaterialSpinner
import KCFloatingActionButton
import FlickrKit
import GooglePlaces
import GoogleMaps
import Alamofire
import MaterialControls
import Analytics

class CountriesViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var sbHeight: NSLayoutConstraint!
    @IBOutlet var loadingBackgroundImageView: UIImageView!
    
    let fab = KCFloatingActionButton()
    let dropMemu = DropDown()
    
    var outboundCityCode: String?
    var autosuggestPlace: GMSAutocompletePrediction?
    
    var budget: Float = 0
    var departDate = String()
    var returnDate = String()
    var requestData = [PlaceBookingInfo]()
    var filterdData = [PlaceBookingInfo]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet var spinnerView: JTMaterialSpinner!
    
    @IBOutlet weak var sb: UISearchBar!
    var searchData = [PlaceBookingInfo]() {
        didSet {
            if searchData.count == 0 {
                self.showLoadingCountriesAlertController()
            }
        }
    }
    
    var filterParams: FilterParams?
    var sortOption: SortOption = .lowestPrice
    var countriesData: NSArray?
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        customizeDropDown()
        someLayout()
        floatinActionButton()
        self.fab.isHidden = true
        
        searchBarSetup()
        self.setupTitle()
        self.loadCountriesData()
        
        self.tableView.register(DestinationTableViewCell.nib, forCellReuseIdentifier: DestinationTableViewCell.reuseIdentifier)
        
        spinnerView.circleLayer.lineWidth = 4.0
        spinnerView.circleLayer.strokeColor = Theme.Colors.brightRed.cgColor
        spinnerView.beginRefreshing()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        suggestCountries()
    }

    func searchBarSetup() {
        sb.delegate = self
        sbHeight.constant = 0
    }
    
    func setupTitle() {
        let inDateFormatter = DateFormatter()
        inDateFormatter.dateFormat = "YYYY-MM-dd"
        
        let outDateFormatter = DateFormatter()
        outDateFormatter.dateFormat = "dd MMM"
        
        let departDate = outDateFormatter.string(from: inDateFormatter.date(from: self.departDate) ?? Date())
        let returnDate = outDateFormatter.string(from: inDateFormatter.date(from: self.returnDate) ?? Date())
        
        self.title = "\(self.autosuggestPlace?.attributedPrimaryText.string ?? ""), \(departDate) - \(returnDate)"
    }
    
    @IBAction func dropDownMenu(_ sender: UIBarButtonItem) {
        dropMemu.show()
    }
    
    func showLoadingCountriesAlertController() {
        let alertController = UIAlertController(title: "", message: "No luck! Try again changing some of your criteria.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .default) { (action) in
            _ = self.navigationController?.popViewController(animated: true)
        }
        
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

extension CountriesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        activityLabel.isHidden = !self.requestData.isEmpty
        loadingBackgroundImageView.isHidden = !self.requestData.isEmpty
        
        if !self.requestData.isEmpty {
            self.fab.isHidden = false
            spinnerView.endRefreshing()
        }
        
        return filterdData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DestinationTableViewCell.reuseIdentifier, for: indexPath) as? DestinationTableViewCell else {
            return DestinationTableViewCell()
        }
        
        cell.bookingInfo = filterdData[indexPath.row]
        cell.onLoadMoreCities = {[weak self] bookingInfo in
            guard let place = bookingInfo else {
                return
            }
            
            SEGAnalytics.shared().track("City_Country_Clicked", properties: ["Budget" : Int(self?.budget ?? 0),
                                                                             "CountryName" : place.countryCode ?? ""])
            
            ClientAPI.shared.loadCitiesToFly(city: self?.autosuggestPlace?.attributedPrimaryText.string ?? "", country: place.countryCode ?? "", departDate: self?.departDate ?? "", returnDate: self?.returnDate ?? "", budget: "\(Int(self?.budget ?? 0))") { places, error in
                
                bookingInfo?.shouldLoadMore = false
                if let bookingPlaces = places {
                    bookingPlaces.forEach{ placeBookingInfo in
                        placeBookingInfo.shouldLoadMore = false
                    }
                    
                    var loadedPlaces = bookingPlaces
                    
                    if let index = bookingPlaces.index(where: { (place) -> Bool in
                        return bookingInfo! == place
                    }) {
                        loadedPlaces.remove(at: index)
                    }
                    
                    loadedPlaces = loadedPlaces.filter({ (place) -> Bool in
                        return (place.hotelPrice ?? 0) > 0
                    })
                    
                    if loadedPlaces.isEmpty {
                        MDToast(text: "\("Just one city of".localized()) \(bookingInfo?.countryName ?? "") \("available".localized())", duration: 2).show()
                    } else {
                        MDToast(text: "\(loadedPlaces.count) \("cities of".localized()) \(bookingInfo?.countryName ?? "") \("added".localized())", duration: 2).show()
                    }
                    
                    self?.requestData.append(contentsOf: loadedPlaces)
                    self?.sortData()
                    self?.filterData()
                }
                
                self?.tableView.reloadData()
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fvc = storyboard?.instantiateViewController(withIdentifier: "final") as! FinalViewController
        
        let destination = self.filterdData[indexPath.row]
        
        fvc.budget = budget
        fvc.departPlace = autosuggestPlace
        fvc.departCityCode = destination.skyScannerCode
        fvc.departDates = departDate
        fvc.returnDates = returnDate
        fvc.selectedPlace = destination
        
        navigationController?.pushViewController(fvc, animated: true)
        
        SEGAnalytics.shared().track("City_City_Selected", properties: ["Budget" : Int(self.budget ?? 0),
                                                                       "CountryName" : destination.name ?? ""])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 220
    }
}

extension CountriesViewController {
    func sortData() {
        switch sortOption {
        case .lowestPrice:
            self.requestData.sort(by: { (place1, place2) -> Bool in
                return place1.totalPrice() < place2.totalPrice()
            })
        case .alphabetically:
            self.requestData.sort(by: { (place1, place2) -> Bool in
                return (place1.name ?? "") < (place2.name ?? "")
            })
        default:
            break
        }
    }
    
    func filterData() {
        self.filterdData = self.requestData
        
        guard let params = self.filterParams else {
            return
        }

        if let priceRange = params.flightCost {
            self.filterdData = self.filterdData.filter({ (place) -> Bool in
                return place.totalPrice() >= priceRange.0 && place.totalPrice() <= priceRange.1
            })
        }
        
        if let themes = params.themes, themes.isEmpty == false {
            self.filterdData = self.filterdData.filter({ (place) -> Bool in
                if let placeThemes = place.themes, placeThemes.isEmpty == false {
                    let placeThemesStripped = Set(placeThemes.map {$0.stripSpacePrefix()})
                    return placeThemesStripped.intersection(Set(themes)).count > 0
                }
                
                return false
            })
        }
        
        if let regions = params.regions {
            if regions.count == 1 && regions.first == .all {
                return
            }
            
            let regionTitles = regions.map{$0.title}
            self.filterdData = self.filterdData.filter({ (place) -> Bool in
                if let region = self.countriesData?.filtered(using: NSPredicate(format: "name LIKE[cd] %@", place.countryName ?? "")).first as? NSDictionary {
                    return regionTitles.contains((region.value(forKey: "region") as? String) ?? "")
                }
                
                return false
            })
        }
    }
    
    func loadCountriesData() {
        if let path = Bundle.main.path(forResource: "regions", ofType: "json") {
            do {
                let jsonData = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                self.countriesData = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSArray
            } catch {}
        }
    }
}
