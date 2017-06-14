//
//  DestinationTableViewCell.swift
//  ClickBye
//
//  Created by Yuriy Berdnikov on 4/7/17.
//  Copyright © 2017 Maxim. All rights reserved.
//

import UIKit
import FlickrKit
import SDWebImage
import JTMaterialSpinner

class DestinationTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "destinationTableViewCell"
    static let nib = UINib(nibName: "DestinationTableViewCell", bundle: nil)
    
    @IBOutlet private var contentImageView: UIImageView!
    @IBOutlet private var totalPriceLabel: UILabel!
    @IBOutlet private var destinationNameLabel: UILabel!
    @IBOutlet private var flightTicketCostsButton: UIButton!
    @IBOutlet private var hotelTicketCostsButton: UIButton!
    @IBOutlet fileprivate var loadMoreButton: UIButton!
    @IBOutlet fileprivate var spinnerView: JTMaterialSpinner!
    @IBOutlet fileprivate var countryNameLabel: UILabel!
    
    var onLoadMoreCities:((_ bookingInfo: PlaceBookingInfo?) -> Void)?
    
    var bookingInfo: PlaceBookingInfo? {
        didSet {
            
            if bookingInfo?.shouldLoadMore == true {
                self.loadMoreButton.isHidden = false

                self.loadMoreButton.setTitle("  \("MORE CITIES OF".localized()) \(bookingInfo?.countryName?.uppercased() ?? "")", for: .normal)
            } else {
                self.loadMoreButton.isHidden = true
                self.countryNameLabel.text = bookingInfo?.countryName
            }
            
            self.destinationNameLabel.text = bookingInfo?.name
            self.totalPriceLabel.text = "\((bookingInfo?.minPrice ?? 0) + (bookingInfo?.hotelPrice ?? 0))€"
            
            flightTicketCostsButton.setTitle(" \(bookingInfo?.minPrice ?? 0)€", for: .normal)
            
            if let hotelPrice = bookingInfo?.hotelPrice, hotelPrice > 0 {
                hotelTicketCostsButton.setTitle(" \(hotelPrice)€", for: .normal)
            }
            
            if let imgUrl = bookingInfo?.imgUrl,
                let photoURL = URL(string: imgUrl)
            {
                self.contentImageView.sd_setImage(with: photoURL)
            } else {
                let userPhotoSearch = FKFlickrPhotosSearch()
                userPhotoSearch.user_id = Constants.Flickr.userID
                userPhotoSearch.text = (bookingInfo?.countryName ?? "") + "-Clickbye"
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
                            self?.bookingInfo?.imgUrl = photoURL.absoluteString
                            self?.contentImageView.sd_setImage(with: photoURL)
                        }
                    } else {
                        let photoSearch = FKFlickrPhotosSearch()
                        photoSearch.text = (self?.bookingInfo?.name ?? "") + " view architecture"
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
                                    self?.bookingInfo?.imgUrl = photoURL.absoluteString
                                    self?.contentImageView.sd_setImage(with: photoURL)
                                }
                            }
                        })
                    }
                })
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.loadMoreButton.layer.cornerRadius = 5
        self.loadMoreButton.layer.masksToBounds = true
        
        self.spinnerView.circleLayer.lineWidth = 3.0
        self.spinnerView.circleLayer.strokeColor = Theme.Colors.brightRed.cgColor
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        loadMoreButton.isHidden = false
        spinnerView.isHidden = true
        contentImageView.image = nil
        totalPriceLabel.text = nil
        destinationNameLabel.text = nil
        flightTicketCostsButton.setTitle(nil, for: .normal)
        hotelTicketCostsButton.setTitle(nil, for: .normal)
        self.countryNameLabel.text = nil
    }
}

extension DestinationTableViewCell {
    
    @IBAction func loadMorebuttonPressed(_ sender: UIButton) {
        self.loadMoreButton.isHidden = true
        self.spinnerView.isHidden = false
        self.spinnerView.beginRefreshing()
        
        self.onLoadMoreCities?(bookingInfo)
    }
}
