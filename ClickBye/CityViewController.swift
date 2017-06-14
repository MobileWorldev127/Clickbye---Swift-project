//
//  CityViewController.swift
//  ClickBye
//
//  Created by Maxim  on 2/17/17.
//  Copyright © 2017 Maxim. All rights reserved.
//

import UIKit
import DropDown
import JTMaterialSpinner
import FlickrKit
import GooglePlaces
import GoogleMaps

class CityViewController: UIViewController {

    var selectedPlace: PlaceBookingInfo?
    var outboundCityCode: String?
    var homePlace: String?
    var departPlace: GMSAutocompletePrediction?
    var budget: Float = 0
    var departDate: String?
    var returnDate: String?
    var cityData = [PlaceBookingInfo]()

    @IBOutlet var loadingBackgroundView: UIImageView!
    @IBOutlet var loadingLabel: UILabel!
    @IBOutlet var spinnerView: JTMaterialSpinner!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBarHeight: NSLayoutConstraint!
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        spinnerView.circleLayer.lineWidth = 4.0
        spinnerView.circleLayer.strokeColor = Theme.Colors.brightRed.cgColor
        
        searchBarHeight.constant = 0
        
        self.loadCities()
    }

    //MARK: Load SourceData
    func loadCities() {
        self.getSuggest()
        self.spinnerView.beginRefreshing()
    }
}

//MARK: Handle TableView
extension CityViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        loadingLabel.isHidden = !cityData.isEmpty
        loadingBackgroundView.isHidden = !cityData.isEmpty
        
        if !cityData.isEmpty {
            spinnerView.endRefreshing()
        }
        
        return cityData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("FlyInfoCell", owner: self, options: nil)?.first as! FlyInfoCell
        
        let placeInfo = cityData[indexPath.row]
        
        cell.selectionStyle = .none
        cell.placeNameLabel.text = placeInfo.name
        cell.priceLabel.text = placeInfo.priceEuro
        
        if let imgUrl = placeInfo.imgUrl,
            let photoURL = URL(string: imgUrl)
        {
            cell.flickrImage.sd_setImage(with: photoURL)
        } else {
            let userPhotoSearch = FKFlickrPhotosSearch()
            userPhotoSearch.user_id = Constants.Flickr.userID
            userPhotoSearch.text = (placeInfo.countryName ?? "") + "-Clickbye"
            userPhotoSearch.media = "photos"
            userPhotoSearch.per_page = "5"
            
            FlickrKit.shared().call(userPhotoSearch, completion: {[weak self] (response, error) in
                let photos: NSDictionary? = response?["photos"] as? NSDictionary
                let photosCount = Int((photos?["total"] as? String) ?? "0") ?? 0
                if photosCount > 0,
                    let photosInfo = photos?["photo"] as? [[NSObject: AnyObject]],
                    let photoInfo = photosInfo.first
                {
                    let photoURL = FlickrKit.shared().photoURL(for: .medium800, fromPhotoDictionary: photoInfo)
                    
                    DispatchQueue.main.async{
                        placeInfo.imgUrl = photoURL.absoluteString
                        cell.flickrImage.sd_setImage(with: photoURL)
                    }
                } else {
                    let photoSearch = FKFlickrPhotosSearch()
                    photoSearch.text = (placeInfo.countryName ?? "") + " view architecture"
                    photoSearch.media = "photos"
                    photoSearch.per_page = "5"
                    FlickrKit.shared().call(photoSearch, completion: { (response, error) in
                        let photos: NSDictionary? = response?["photos"] as? NSDictionary
                        let photosCount = Int((photos?["total"] as? String) ?? "0") ?? 0
                        if photosCount > 0,
                            let photosInfo = photos?["photo"] as? [[NSObject: AnyObject]],
                            let photoInfo = photosInfo.first
                        {
                            let photoURL = FlickrKit.shared().photoURL(for: .medium800, fromPhotoDictionary: photoInfo)
                            
                            DispatchQueue.main.async{
                                placeInfo.imgUrl = photoURL.absoluteString
                                cell.flickrImage.sd_setImage(with: photoURL)
                            }
                        }
                    })
                }
            })
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fvc = storyboard?.instantiateViewController(withIdentifier: "final") as! FinalViewController
        
        fvc.budget = budget
        fvc.departPlace = departPlace
        fvc.departCityCode = homePlace
        fvc.departDates = departDate
        fvc.returnDates = returnDate
        fvc.selectedPlace = self.cityData[indexPath.row]
        
        navigationController?.pushViewController(fvc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 220
    }
}
