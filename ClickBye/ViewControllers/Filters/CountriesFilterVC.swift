//
//  CountriesFilterVC.swift
//  ClickBye
//
//  Created by Maxim  on 2/21/17.
//  Copyright © 2017 Maxim. All rights reserved.
//

import UIKit
import MaterialControls
import Localize_Swift
import TTRangeSlider
import SnapKit
import KeychainAccess

class CountriesFilterVC: UIViewController {
    static let storyboardID = "countryFilter"
    static var countriesFilterVC: CountriesFilterVC? {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: CountriesFilterVC.storyboardID) as? CountriesFilterVC
    }
    
    @IBOutlet var regionCheckboxesContainerView: UIView?
    @IBOutlet var regionCheckboxes: [UIButton]!
    @IBOutlet var flightCostsSlider: TTRangeSlider!
    
    @IBOutlet var themesSubtitleLabel: UILabel!
    @IBOutlet var themesStackView: UIStackView!
    
    var flightData: [PlaceBookingInfo]?
    var maxBudget : Int?
    var filterParams = FilterParams()
    
    var onApplyFilters: ((_ filterParams: FilterParams) -> Void)?
    
    fileprivate var themeButtons = [UIButton]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureUI()
    }
}

extension CountriesFilterVC {
    @IBAction func resetButtonPressed(_ sender: UIButton) {
        _ = regionCheckboxes.map {$0.isSelected = false}
        regionCheckboxes.first?.isSelected = true
        
        flightCostsSlider.selectedMinimum = flightCostsSlider.minValue
        flightCostsSlider.selectedMaximum = flightCostsSlider.maxValue
        
        _ = themeButtons.map {$0.isSelected = false}
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func flightCostsValueChanged(_ sender: TTRangeSlider) {
        
    }
    
    @IBAction func applyButtonPressed(_ sender: UIButton) {
        self.filterParams.regions?.removeAll()
        for (index, vaue) in self.regionCheckboxes.enumerated() {
            if vaue.isSelected,
                let region = Regions(rawValue: index)
            {
                self.filterParams.regions?.append(region)
            }
        }
        
        self.filterParams.flightCost = (Int(self.flightCostsSlider.selectedMinimum), Int(self.flightCostsSlider.selectedMaximum))
        
        self.filterParams.themes?.removeAll()
        self.filterParams.themes = self.themeButtons.filter{$0.isSelected == true}.map{$0.title(for: .normal)?.stripSpacePrefix() ?? ""}
        
        self.onApplyFilters?(self.filterParams)
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func regionButtonPressed(_ sender: UIButton) {
        if sender == self.regionCheckboxes.first {
            _ = self.regionCheckboxes.map {$0.isSelected = false}
        } else if self.regionCheckboxes.first?.isSelected == true {
            self.regionCheckboxes.first?.isSelected = false
        }
        
        sender.isSelected = !sender.isSelected
    }
    
    func themeButtonPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
}

extension CountriesFilterVC {
    func configureUI() {
        flightCostsSlider.tintColorBetweenHandles = UIColor.black
        flightCostsSlider.lineHeight = 2
        
        flightCostsSlider.minValue = 0
        flightCostsSlider.maxValue = Float(self.maxBudget ?? Constants.Budget.defaultBudget)
        flightCostsSlider.selectedMinimum = Float(self.filterParams.flightCost?.0 ?? 0)
        flightCostsSlider.selectedMaximum = Float(self.filterParams.flightCost?.1 ?? Int(flightCostsSlider.maxValue))
        
        filterParams.regions?.forEach { region in
            self.regionCheckboxes[region.rawValue].isSelected = true
        }
        
        if Keychain(service: Constants.Keychain.appServiceID)["email"]?.isEmpty == true {
            self.themesStackView.alpha = 0.5
            self.themesStackView.isUserInteractionEnabled = false
            self.setupFilterThemes(Constants.Theme.defaultThemes().map{$0.rawValue})
        } else {
            var themes = [String]()
            flightData?.forEach { placeBookingInfo in
                themes.append(contentsOf: placeBookingInfo.themes ?? [])
            }
            
            self.setupFilterThemes(Array(Set(themes.map{$0.stripSpacePrefix()})).sorted())
            self.themesStackView.alpha = 1
            self.themesStackView.isUserInteractionEnabled = true
            self.themesSubtitleLabel.isHidden = true
        }
    }
    
    func setupFilterThemes(_ themes: [String]) {
        themes.forEach { theme in
            let button = UIButton()
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.setTitle(" \(theme)", for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.setImage(UIImage(named: "checkbox-blank"), for: .normal)
            button.setImage(UIImage(named: "checkbox-marked"), for: .selected)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(CountriesFilterVC.themeButtonPressed(_:)), for: .touchUpInside)
            button.snp.makeConstraints { make in
                make.height.equalTo(30)
            }
            
            button.isSelected = (self.filterParams.themes?.contains(theme) == true)
            
            themeButtons.append(button)
            self.themesStackView.addArrangedSubview(button)
        }
    }
}
