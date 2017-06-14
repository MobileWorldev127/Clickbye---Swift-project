//
//  SortViewController.swift
//  ClickBye
//
//  Created by Yuriy Berdnikov on 4/19/17.
//  Copyright © 2017 Maxim. All rights reserved.
//

import UIKit

enum SortOption: Int {
    case lowestPrice,
    alphabetically,
    flightDuration,
    departureTime,
    arrivalTime
    
    static func sortOptions() -> [SortOption] {
        return [.lowestPrice, .alphabetically, .flightDuration, .departureTime, .arrivalTime]
    }
}

class SortViewController: UIViewController {
    
    static let storyboardID = "sortViewController"
    static var sortViewController: SortViewController? {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: SortViewController.storyboardID) as? SortViewController
    }
    
    @IBOutlet var lowestPriceButton: ISRadioButton?
    @IBOutlet var alphabeticallySortButton: ISRadioButton?
    @IBOutlet var flightDurationOption: ISRadioButton?
    @IBOutlet var departureTimeOption: ISRadioButton?
    @IBOutlet var arrivalTimeOption: ISRadioButton?
    
    var defaultSortOption: SortOption = .lowestPrice
    var sortOptions: [SortOption]?
    var onSortOptionSelected: ((_ option: SortOption) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SortOption.sortOptions().forEach { sortOption in
            if self.sortOptions?.contains(sortOption) == false {
                switch sortOption {
                case .lowestPrice:
                    lowestPriceButton?.removeFromSuperview()
                case .alphabetically:
                    alphabeticallySortButton?.removeFromSuperview()
                case .flightDuration:
                    flightDurationOption?.removeFromSuperview()
                case .departureTime:
                    departureTimeOption?.removeFromSuperview()
                case .arrivalTime:
                    arrivalTimeOption?.removeFromSuperview()
                }
            }
        }
        
        switch defaultSortOption {
        case .lowestPrice:
            lowestPriceButton?.isSelected = true
        case .alphabetically:
            alphabeticallySortButton?.isSelected = true
        case .flightDuration:
            flightDurationOption?.isSelected = true
        case .departureTime:
            departureTimeOption?.isSelected = true
        case .arrivalTime:
            arrivalTimeOption?.isSelected = true
        }
    }
}

extension SortViewController {
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        if lowestPriceButton?.isSelected == true {
            self.onSortOptionSelected?(.lowestPrice)
        } else if alphabeticallySortButton?.isSelected == true {
            self.onSortOptionSelected?(.alphabetically)
        } else if flightDurationOption?.isSelected == true {
            self.onSortOptionSelected?(.flightDuration)
        } else if departureTimeOption?.isSelected == true {
            self.onSortOptionSelected?(.departureTime)
        } else if arrivalTimeOption?.isSelected == true {
            self.onSortOptionSelected?(.arrivalTime)
        }

        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
