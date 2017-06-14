//
//  FinalViewController.swift
//  ClickBye
//
//  Created by Maxim  on 2/19/17.
//  Copyright © 2017 Maxim. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage
import JTMaterialSpinner
import GooglePlaces
import GoogleMaps
import ForecastIO
import KCFloatingActionButton
import Analytics

class FinalViewController: UIViewController {
    
    var nextSwitch: Int = 0
    var backSwitch: Int = 0
    
    var selectedCityCode: String?
    var selectedPlace: PlaceBookingInfo?
    
    var departPlace: GMSAutocompletePrediction?
    var budget: Float = 0
    var departCityCode: String?
    var departDates: String?
    var returnDates: String?
    var query: String?
    var queryURL: URL?
    
    var flightRoutes: [FlightRouteDetails]?
    
    var link: String?
    var selectedOutbound: FlightDetails?
    var outbounds: [FlightRouteDetails]?
    var inbounds: [FlightRouteDetails]?
    
    var placesFetcher: GMSAutocompleteFetcher?
    
    @IBOutlet var loadingBackgroundView: UIImageView!
    @IBOutlet var loadingLabel: UILabel!
    @IBOutlet var spinnerView: JTMaterialSpinner!
    @IBOutlet var headerImageView: UIImageView!
    @IBOutlet var datesLabel: UILabel!
    @IBOutlet var datesCalendarIcon: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var likeButton: UIButton?
    @IBOutlet weak var bookBttn: UIButton!
    @IBOutlet weak var holderView: UIView!
    /* Depart Labels */
    @IBOutlet weak var outDepartTime: UILabel!
    @IBOutlet weak var outArrivalTime: UILabel!
    @IBOutlet weak var outAirport: UILabel!
    @IBOutlet weak var outArrivalAirport: UILabel!
    @IBOutlet weak var outDepartDates: UILabel!
    @IBOutlet weak var outArrivalDates: UILabel!
    @IBOutlet weak var outFlightTime: UILabel!
    @IBOutlet weak var outAirlines: UILabel!
    /* Return Labbels */
    @IBOutlet weak var inDepartTime: UILabel!
    @IBOutlet weak var inArrivalTime: UILabel!
    @IBOutlet weak var inAirport: UILabel!
    @IBOutlet weak var inDepartAirPort: UILabel!
    @IBOutlet weak var inDepartDates: UILabel!
    @IBOutlet weak var inArrivalDates: UILabel!
    @IBOutlet weak var inFlightTime: UILabel!
    @IBOutlet weak var inAirLines: UILabel!
    @IBOutlet weak var fullPricelabel: UILabel!
    @IBOutlet weak var cityNameLabel: UILabel?
    @IBOutlet var temperatureButton: UIButton!
    @IBOutlet var poiLabel: UILabel!
    @IBOutlet var infoTextLabel: UILabel!
    
    let fab = KCFloatingActionButton()
    
    var sortOption: SortOption = .lowestPrice
    var fromFilterParams: FilterParams?
    var toFilterParams: FilterParams?
    
    let apiKey = "?apikey=cl349986435759049486846710915145"
    var parameters: [String : Any] = [
        "apiKey" : "cl349986435759049486846710915145" ,
        "country" : Locale.current.regionCode ?? "US",
        "currency" : "EUR",
        "locale" : Locale.current.languageCode ?? "en",
        "originplace" : "SFO-iata",
        "destinationplace" : "BOS-iata",
        "outbounddate" : "2017-02-27",
        "inbounddate" : "2017-03-07",
        "adults" : "1",
        "groupPricing" : "true"
    ]
    let headers: HTTPHeaders = [
        "Accept" : "application/json"
    ]
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        spinnerView.circleLayer.lineWidth = 4.0
        spinnerView.circleLayer.strokeColor = Theme.Colors.brightRed.cgColor
        
        self.parameters["outbounddate"] = self.departDates
        self.parameters["inbounddate"] = self.returnDates
        self.parameters["originplace"] = self.departPlace?.attributedPrimaryText.string ?? ""
        
        floatinActionButton()
        self.fab.isHidden = true
        
        self.loadData()
        
        if let city = self.selectedPlace?.name {
            self.cityNameLabel?.text = "To \(city)"
        }
        
        if let imgUrl = self.selectedPlace?.imgUrl,
            let photoURL = URL(string :imgUrl)
        {
            self.headerImageView.sd_setImage(with: photoURL)

        }
        
        setupDatesLabel()
        //self.likeButton?.isHidden = User.currentUser != nil ? true : false
        
        tableView.alpha = 1
        holderView.alpha = 0
        bookBttn.alpha = 0
        self.infoTextLabel.alpha = 1
        self.datesLabel.isHidden = false
        self.datesCalendarIcon.isHidden = false
        self.temperatureButton.isHidden = false
        self.poiLabel.isHidden = false
        
        self.inbounds = nil
        self.tableView.reloadData()
        self.infoTextLabel.text = "All prices include the return. Please choose your outward.".localized()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    //MARK: Actions
    @IBAction func backButton(_ sender: UIButton) {
        
        if inbounds == nil {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            _ = self.navigationController?.popViewController(animated: true)
            
            return
        }
        
        tableView.alpha = 1
        holderView.alpha = 0
        bookBttn.alpha = 0
        self.infoTextLabel.alpha = 1
        self.datesLabel.isHidden = false
        self.datesCalendarIcon.isHidden = false
        self.temperatureButton.isHidden = false
        self.poiLabel.isHidden = false
        
        self.inbounds = nil
        self.tableView.reloadData()
        self.infoTextLabel.text = "All prices include the return. Please choose your outward.".localized()
        if let city = self.selectedPlace?.name {
            self.cityNameLabel?.text = "\("To".localized()) \(city)"
        }
    }
    
    @IBAction func bookMe(_ sender: UIButton) {
        sendDataToWebViewController()
    }
    
    //MARK: Helpers
    func loadData() {
        self.getAvailableFlights()
        self.spinnerView.beginRefreshing()
    }
    
    func finalViewInfo() {
        loadingLabel.isHidden = true
        loadingBackgroundView.isHidden = true
        spinnerView.endRefreshing()
        
        setupPlacePOI()
        
        if self.flightRoutes?.isEmpty == true {
            return
        }
        
        self.fab.isHidden = false
        
        var duplicatedOutboundFlights = Set<FlightDetails>()
        self.outbounds = [FlightRouteDetails]()
        flightRoutes?.forEach { flightRoute in
            if let outbound = flightRoute.from,
                !duplicatedOutboundFlights.contains(outbound) {
                duplicatedOutboundFlights.insert(outbound)
                self.outbounds?.append(flightRoute)
            }
        }
        
        self.tableView.reloadData()
    }
    
    func sendDataToWebViewController() {
        let fvc = storyboard?.instantiateViewController(withIdentifier: "web") as! WebViewController
        fvc.link = link!
        fvc.title = "Flight Details"
        navigationController?.pushViewController(fvc, animated: true)
    }
}

extension FinalViewController {
    //MARK: Helpers
    
    func setupPlacePOI() {
        // Set up the autocomplete filter.
        let filter = GMSAutocompleteFilter()
        filter.type = .establishment
        
        // Create the fetcher.
        placesFetcher = GMSAutocompleteFetcher()
        placesFetcher?.delegate = self
        placesFetcher?.sourceTextHasChanged(selectedPlace?.countryName ?? "")
    }
    
    func fetchPOIList(city: String) {
        
        let URL = try! "http://beta.clickbye.com/api-public/attractions/search?city=\(city.replacingOccurrences(of: " ", with: "+"))&lang=eng".asURL()
        
        Alamofire.request(URL).responseJSON {[weak self] result in
            if let result = result.value,
                let results = result as? NSArray,
                results.count > 0
            {
                self?.poiLabel.text = results.componentsJoined(by: ", ")
                UIView.animate(withDuration: 0.25, animations: {
                    self?.view.layoutIfNeeded()
                })
            }
        }
    }
    
    func setupDatesLabel() {
        let inDateFormatter = DateFormatter()
        inDateFormatter.dateFormat = "YYYY-MM-dd"
        
        let outDateFormatter = DateFormatter()
        outDateFormatter.dateFormat = "EEE. dd MMM."
        
        if let departDate = departDates,
            let dateDepart = inDateFormatter.date(from: departDate),
            let returnDate = self.returnDates,
            let dateReturn = inDateFormatter.date(from: returnDate)
        {
            let departDateString = outDateFormatter.string(from: dateDepart)
            let returnDateString = outDateFormatter.string(from: dateReturn)
            
            self.datesLabel.text = "\(departDateString.replacingOccurrences(of: "..", with: ".")) - \(returnDateString.replacingOccurrences(of: "..", with: "."))"
        }
    }
    
    func showFlightData(flight: FlightRouteDetails?) {
        
        if let outboundFlight = flight?.from,
            let inboundFlight = flight?.to
        {
            outDepartTime.text = outboundFlight.departureDate?.stringFromFormat("HH'h'mm'm'")
            outArrivalTime.text = outboundFlight.arrivalDate?.stringFromFormat("HH'h'mm'm'")
            outAirport.text = outboundFlight.originStationPlace?.code
            outArrivalAirport.text = outboundFlight.destinationStationPlace?.code
            outDepartDates.text = outboundFlight.departureDate?.stringFromFormat("EEE. dd MMM.").replacingOccurrences(of: "..", with: ".")
            outArrivalDates.text = outboundFlight.arrivalDate?.stringFromFormat("EEE. dd MMM.").replacingOccurrences(of: "..", with: ".")
            outFlightTime.text = outboundFlight.durationReadableText
            outAirlines.text = outboundFlight.carrier?.name
            
            inDepartTime.text = inboundFlight.departureDate?.stringFromFormat("HH'h'mm'm'")
            inArrivalTime.text = inboundFlight.arrivalDate?.stringFromFormat("HH'h'mm'm'")
            inAirport.text = inboundFlight.originStationPlace?.code
            inDepartAirPort.text = inboundFlight.destinationStationPlace?.code
            inDepartDates.text = inboundFlight.departureDate?.stringFromFormat("EEE. dd MMM.").replacingOccurrences(of: "..", with: ".")
            inArrivalDates.text = inboundFlight.arrivalDate?.stringFromFormat("EEE. dd MMM.").replacingOccurrences(of: "..", with: ".")
            inFlightTime.text = inboundFlight.durationReadableText
            inAirLines.text = inboundFlight.carrier?.name
        }
        
        fullPricelabel.text = String(format: "%.0f€", flight?.agents?.first?.price ?? 0)
    }
}

//MARK: Handle TableView
extension FinalViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let datasource = self.inbounds {
            return datasource.count
        }
        
        return self.outbounds?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("DepartReturn", owner: self, options: nil)?.first as! DepartReturnCell
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor.clear
        
        var datasource: [FlightRouteDetails]?
        var flightDetails: FlightDetails?
        if let _ = self.inbounds {
            datasource = self.inbounds
            flightDetails = datasource?[indexPath.row].to
        } else {
            datasource = self.outbounds
            flightDetails = datasource?[indexPath.row].from
        }
        
        if let flightInfo = datasource?[indexPath.row] {
            
            if let originStationPlaceCode = flightDetails?.originStationPlace?.code,
                let departureTime = flightDetails?.departureDate,
                let destinationStationPlaceCode = flightDetails?.destinationStationPlace?.code,
                let arrivalTime = flightDetails?.arrivalDate
            {
                cell.departLabel.text = "\(originStationPlaceCode): \(departureTime.stringFromFormat("HH:mm")) - \(destinationStationPlaceCode): \(arrivalTime.stringFromFormat("HH:mm"))"
            }
            
            cell.carrierName.text = flightDetails?.carrier?.name
            
            if let price = flightInfo.agents?.first?.price {
                cell.priceLabel.text = String(format: "%.0f€", price)
            }
            
            cell.flightTime.text = flightDetails?.durationReadableText
            
            if let carriedImg = flightDetails?.carrier?.imageUrl,
                let carriedImgURL = URL(string: carriedImg) {
                cell.carrierImage.sd_setImage(with: carriedImgURL)
            }
            
            switch flightDetails?.stops?.count {
            case .some(0):
                cell.stopsLabel.text = "Direct".localized()
            case .some(1):
                cell.stopsLabel.text = "1 Stop".localized()
            default:
                cell.stopsLabel.text = "\(flightDetails?.stops?.count ?? 2) \("stops".localized())"
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if let datasource = self.inbounds {
            let inboundFlight = datasource[indexPath.row];
            self.link = inboundFlight.agents?.first?.deepLink;
            
            SEGAnalytics.shared().track("Return_Outbound_Selected",
                                        properties: ["AirlineCompany" : inboundFlight.to?.carrier?.name ?? "",
                                                     "DestinationCity" : self.selectedPlace?.name ?? "",
                                                     "Budget" : self.budget,
                                                     "RealPrice" : inboundFlight.agents?.first?.price ?? 0])
            
            sendDataToWebViewController()
        } else {
            self.infoTextLabel.text = "All prices include the outward. Please choose your return.".localized()
            
            if let outboundFlight = self.outbounds?[indexPath.row].from {
                self.selectedOutbound = outboundFlight
                
                var inboundsFlights = [FlightRouteDetails]()
                flightRoutes?.forEach { flightRoute in
                    if outboundFlight == flightRoute.from {
                        inboundsFlights.append(flightRoute)
                    }
                }
                
                if !inboundsFlights.isEmpty {
                    self.inbounds = inboundsFlights
                }
                
                SEGAnalytics.shared().track("Depart_Outbound_Selected",
                                            properties: ["AirlineCompany" : outboundFlight.carrier?.name ?? "",
                                                         "DestinationCity" : self.selectedPlace?.name ?? "",
                                                         "Budget" : self.budget,
                                                         "RealPrice" : self.outbounds?[indexPath.row].agents?.first?.price ?? 0])
            }
            
            if let city = self.selectedPlace?.name {
                self.cityNameLabel?.text = "\("From".localized()) \(city)"
            }
            
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension FinalViewController: GMSAutocompleteFetcherDelegate {
    func didFailAutocompleteWithError(_ error: Error) {
        
    }
    
    func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
        if predictions.isEmpty {
            return
        }
        
        if let prediction = predictions.first {
            GMSPlacesClient.shared().lookUpPlaceID(prediction.placeID ?? "", callback: { [weak self] (place, error) in
                if error != nil {
                    return
                }
                
                guard let place = place else {
                    return
                }
                
                self?.fetchPOIList(city: prediction.attributedPrimaryText.string)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "YYYY-MM-dd"
                
                guard let departDateStr = self?.departDates,
                    let departDate = dateFormatter.date(from: departDateStr) else
                {
                    return
                }
                
                var forecastDate = departDate
                if forecastDate < (Date() + 1.month) {
                    forecastDate = departDate
                } else {
                    forecastDate = forecastDate - 1.year
                }
                
                let client = DarkSkyClient(apiKey: Constants.Forecast.apiKey)
                client.units = .si
                client.getForecast(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude, time: departDate, completion: {[weak self] result in
                    switch result {
                    case .success(let currentForecast, _):
                        DispatchQueue.main.async {
                            self?.temperatureButton.setTitle(" \(Int(currentForecast.currently?.temperature ?? 0))°C", for: .normal)
                        }
                    case .failure(_):
                        break
                    }
                })
            })
        }
    }
}

extension FinalViewController {
    func floatinActionButton() {
        
        let item = KCFloatingActionButtonItem()
        let sort = KCFloatingActionButtonItem()
        item.buttonColor = Theme.Colors.brightRed
        item.circleShadowColor = UIColor.flatBlack
        item.titleShadowColor = UIColor.flatBlack
        item.title = "Sort".localized()
        item.icon = #imageLiteral(resourceName: "sort")
        item.iconImageView.contentMode = .center
        item.handler = { item in
            self.presentSortViewController()
        }
        sort.buttonColor = Theme.Colors.brightRed
        sort.circleShadowColor = UIColor.flatBlack
        sort.titleShadowColor = UIColor.flatBlack
        sort.title = "Filter".localized()
        sort.icon = #imageLiteral(resourceName: "filter")
        sort.iconImageView.contentMode = .center
        sort.handler = { item in
            self.presentFilterViewCountroller()
        }
        
        fab.buttonColor = Theme.Colors.brightRed
        fab.shadowColor = UIColor.flatBlack
        fab.plusColor = UIColor.flatWhite
        fab.addItem(item: item)
        fab.addItem(item: sort)
        fab.sticky = true
        
        self.view.addSubview(fab)
    }
}

extension FinalViewController {
    func sortData() {
        switch sortOption {
        case .lowestPrice:
            if let inboundsFlights = self.inbounds {
                self.inbounds = inboundsFlights.sorted(by: { (routeDetails1, routeDetails2) -> Bool in
                    (routeDetails1.agents?.first?.price ?? 0) < (routeDetails2.agents?.first?.price ?? 0)
                })
            } else if let outboundsFlights = self.outbounds {
                self.outbounds = outboundsFlights.sorted(by: { (routeDetails1, routeDetails2) -> Bool in
                    (routeDetails1.agents?.first?.price ?? 0) < (routeDetails2.agents?.first?.price ?? 0)
                })
            }
            
        case .flightDuration:
            if let inboundsFlights = self.inbounds {
                self.inbounds = inboundsFlights.sorted(by: { (routeDetails1, routeDetails2) -> Bool in
                    (routeDetails1.to?.duration ?? 0) < (routeDetails2.to?.duration ?? 0)
                })
            } else if let outboundsFlights = self.outbounds {
                self.outbounds = outboundsFlights.sorted(by: { (routeDetails1, routeDetails2) -> Bool in
                    (routeDetails1.from?.duration ?? 0) < (routeDetails2.from?.duration ?? 0)
                })
            }
            
        case .departureTime:
            if let inboundsFlights = self.inbounds {
                self.inbounds = inboundsFlights.sorted(by: { (routeDetails1, routeDetails2) -> Bool in
                    (routeDetails1.to?.departureDate ?? Date()) < (routeDetails2.to?.departureDate ?? Date())
                })
            } else if let outboundsFlights = self.outbounds {
                self.outbounds = outboundsFlights.sorted(by: { (routeDetails1, routeDetails2) -> Bool in
                    (routeDetails1.from?.departureDate ?? Date()) < (routeDetails2.from?.departureDate ?? Date())
                })
            }
            
        case .arrivalTime:
            if let inboundsFlights = self.inbounds {
                self.inbounds = inboundsFlights.sorted(by: { (routeDetails1, routeDetails2) -> Bool in
                    (routeDetails1.to?.arrivalDate ?? Date()) < (routeDetails2.to?.arrivalDate ?? Date())
                })
            } else if let outboundsFlights = self.outbounds {
                self.outbounds = outboundsFlights.sorted(by: { (routeDetails1, routeDetails2) -> Bool in
                    (routeDetails1.from?.arrivalDate ?? Date()) < (routeDetails2.from?.arrivalDate ?? Date())
                })
            }
            
        default:
            break
        }
    }
    
    func filterData() {
        if let _ = self.inbounds {
            self.inbounds = nil
            
            var inboundsFlights = [FlightRouteDetails]()
            flightRoutes?.forEach { flightRoute in
                if self.selectedOutbound == flightRoute.from {
                    inboundsFlights.append(flightRoute)
                }
            }
            
            if !inboundsFlights.isEmpty {
                self.inbounds = inboundsFlights
            }
        } else {
            var duplicatedOutboundFlights = Set<FlightDetails>()
            self.outbounds = [FlightRouteDetails]()
            flightRoutes?.forEach { flightRoute in
                if let outbound = flightRoute.from,
                    !duplicatedOutboundFlights.contains(outbound) {
                    duplicatedOutboundFlights.insert(outbound)
                    self.outbounds?.append(flightRoute)
                }
            }
        }
        
        var filterParams: FilterParams?
        if let _ = self.inbounds {
            filterParams = self.toFilterParams
        } else {
            filterParams = self.fromFilterParams
        }
        
        guard let params = filterParams else {
            return
        }
        
        if params.departureAirports?.isEmpty == false {
            if let _ = self.inbounds {
                self.inbounds = self.inbounds?.filter{ flightDetails -> Bool in
                    return params.departureAirports?.contains(flightDetails.to?.originStationPlace?.name ?? "") ?? false
                }
            } else {
                self.outbounds = self.outbounds?.filter{ flightDetails -> Bool in
                    return params.departureAirports?.contains(flightDetails.from?.originStationPlace?.name ?? "") ?? false
                }
            }
        }
        
        if params.arrivalAirports?.isEmpty == false {
            if let _ = self.inbounds {
                self.inbounds = self.inbounds?.filter{ flightDetails -> Bool in
                    return params.arrivalAirports?.contains(flightDetails.from?.originStationPlace?.name ?? "") ?? false
                }
            } else {
                self.outbounds = self.outbounds?.filter{ flightDetails -> Bool in
                    return params.arrivalAirports?.contains(flightDetails.to?.originStationPlace?.name ?? "") ?? false
                }
            }
        }
        
        if let durationTime = params.flightDuration {
            if let _ = self.inbounds {
                self.inbounds = self.inbounds?.filter{ flightDetails -> Bool in
                    return (flightDetails.to?.duration ?? 0) <= durationTime
                }
            } else {
                self.outbounds = self.outbounds?.filter{ flightDetails -> Bool in
                    return (flightDetails.from?.duration ?? 0) <= durationTime
                }
            }
        }
        
        if let departureTime = params.departureTime {
            if let _ = self.inbounds {
                self.inbounds = self.inbounds?.filter{ flightDetails -> Bool in
                    return (flightDetails.to?.departureDate?.hour ?? 0) >= departureTime.0 &&
                        (flightDetails.to?.departureDate?.hour ?? 0) <= departureTime.1
                }
            } else {
                self.outbounds = self.outbounds?.filter{ flightDetails -> Bool in
                    return ((flightDetails.from?.departureDate?.hour ?? 0) >= departureTime.0) &&
                        ((flightDetails.from?.departureDate?.hour ?? 0) <= departureTime.1)
                }
            }
        }
        
        if let arrivalTime = params.arrivalTime {
            if let _ = self.inbounds {
                self.inbounds = self.inbounds?.filter{ flightDetails -> Bool in
                    return (flightDetails.to?.arrivalDate?.hour ?? 0) >= arrivalTime.0 &&
                        (flightDetails.to?.arrivalDate?.hour ?? 0) <= arrivalTime.1
                }
            } else {
                self.outbounds = self.outbounds?.filter{ flightDetails -> Bool in
                    return ((flightDetails.from?.arrivalDate?.hour ?? 0) >= arrivalTime.0) &&
                        ((flightDetails.from?.arrivalDate?.hour ?? 0) <= arrivalTime.1)
                }
            }
        }
        
        if let stops = params.stops, stops.count > 0 {
            if let _ = self.inbounds {
                self.inbounds = self.inbounds?.filter{ flightDetails -> Bool in
                    var flighStops: FlighStops = .direct
                    switch flightDetails.to?.stops?.count {
                    case .some(0):
                        flighStops = .direct
                    case .some(1):
                        flighStops = .oneStop
                    default:
                        flighStops = .moreThanTwoStops
                    }
                    
                    return stops.contains(flighStops)
                }
            } else {
                self.outbounds = self.outbounds?.filter{ flightDetails -> Bool in
                    var flighStops: FlighStops = .direct
                    switch flightDetails.from?.stops?.count {
                    case .some(0):
                        flighStops = .direct
                    case .some(1):
                        flighStops = .oneStop
                    default:
                        flighStops = .moreThanTwoStops
                    }
                    
                    return stops.contains(flighStops)
                }
            }
        }
        
        if params.airlines?.isEmpty == false {
            if let _ = self.inbounds {
                self.inbounds = self.inbounds?.filter{ flightDetails -> Bool in
                    return params.airlines?.contains(flightDetails.to?.carrier?.name ?? "") ?? false
                }
            } else {
                self.outbounds = self.outbounds?.filter{ flightDetails -> Bool in
                    return params.airlines?.contains(flightDetails.from?.carrier?.name ?? "") ?? false
                }
            }
        }
    }
    
    //MARK: KCFloatingActionButtonItem selectors
    func presentSortViewController() {
        if let sortViewController = SortViewController.sortViewController {
            
            sortViewController.onSortOptionSelected = { sortOption in
                self.sortOption = sortOption
                self.sortData()
                self.filterData()
                self.tableView.reloadData()
            }
            
            sortViewController.defaultSortOption = self.sortOption
            sortViewController.sortOptions = [.lowestPrice, .flightDuration, .departureTime, .arrivalTime]
            sortViewController.modalTransitionStyle = .crossDissolve
            sortViewController.modalPresentationStyle = .overFullScreen
            self.present(sortViewController, animated: true, completion: nil)
        }
    }
    
    func presentFilterViewCountroller() {
        if let fvc = TicketsFilterViewController.ticketsFilterViewController {
            
            if let _ = self.inbounds {
                var inboundsFlights = [FlightRouteDetails]()
                flightRoutes?.forEach { flightRoute in
                    if self.selectedOutbound == flightRoute.from {
                        inboundsFlights.append(flightRoute)
                    }
                }
                
                fvc.flightData = inboundsFlights
                if let params = self.toFilterParams {
                    fvc.filterParams = params
                }
            } else {
                var duplicatedOutboundFlights = Set<FlightDetails>()
                var outbounds = [FlightRouteDetails]()
                flightRoutes?.forEach { flightRoute in
                    if let outbound = flightRoute.from,
                        !duplicatedOutboundFlights.contains(outbound) {
                        duplicatedOutboundFlights.insert(outbound)
                        outbounds.append(flightRoute)
                    }
                }
                
                fvc.flightData = outbounds
                if let params = self.fromFilterParams {
                    fvc.filterParams = params
                }
            }

            fvc.isDeparture = (self.inbounds == nil)

            fvc.onApplyFilters = { [weak self] params in
                if let _ = self?.inbounds {
                    self?.toFilterParams = params
                } else {
                    self?.fromFilterParams = params
                }

                self?.sortData()
                self?.filterData()
                self?.tableView.reloadData()
            }
            
            fvc.modalTransitionStyle = .crossDissolve
            fvc.modalPresentationStyle = .overFullScreen
            self.present(fvc, animated: true, completion: nil)
        }
    }
}
