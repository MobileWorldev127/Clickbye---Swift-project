//
//  CountriesLogic.swift
//  ClickBye
//
//  Created by Maxim  on 2/16/17.
//  Copyright © 2017 Maxim. All rights reserved.
//

import UIKit
import DropDown
import KCFloatingActionButton
import ChameleonFramework
import Analytics

extension CountriesViewController {
    
    func someLayout() {
//        searchBarHeight.constant = 0
    }
    
    func labelsLogic() {
        
    }
    
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
    
    func customizeDropDown() {

    }
    
    func barAnimateExpand() {
//        UIView.animate(withDuration: 0.5, animations: {
//            self.searchBarHeight.constant = 44
//        })
    }
    
    func barAnimateCollapse() {
//        UIView.animate(withDuration: 0.5, animations: {
//            self.searchBarHeight.constant = 0
//        })
    }
}

extension CountriesViewController {
    //MARK: KCFloatingActionButtonItem selectors
    func presentSortViewController() {
        if let sortViewController = SortViewController.sortViewController {
            filterdData.removeAll()
            
            sortViewController.onSortOptionSelected = { [weak self] sortOption in
                self?.sortOption = sortOption
                self?.sortData()
                self?.filterData()
                self?.tableView.reloadData()
            }
            
            sortViewController.defaultSortOption = self.sortOption
            sortViewController.sortOptions = [.alphabetically, .lowestPrice]
            sortViewController.modalTransitionStyle = .crossDissolve
            sortViewController.modalPresentationStyle = .overFullScreen
            self.present(sortViewController, animated: true, completion: nil)
        }
    }
    
    func presentFilterViewCountroller() {
        if let fvc = CountriesFilterVC.countriesFilterVC {
            if let params = self.filterParams {
                fvc.filterParams = params
            }
            
            fvc.maxBudget = Int(self.budget)
            fvc.flightData = self.requestData
            fvc.onApplyFilters = { [weak self] params in
                self?.filterParams = params
                self?.sortData()
                self?.filterData()
                self?.tableView.reloadData()
                
                SEGAnalytics.shared().track("City_Filter_Clicked", properties: ["Budget" : Int(self?.budget ?? 0)])
            }
            
            fvc.modalTransitionStyle = .crossDissolve
            fvc.modalPresentationStyle = .overFullScreen
            self.present(fvc, animated: true, completion: nil)
        }
    }
}
