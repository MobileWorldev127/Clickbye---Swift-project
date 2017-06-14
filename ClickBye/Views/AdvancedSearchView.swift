//
//  AdvancedSearchView.swift
//  ClickBye
//
//  Created by Maxim  on 11/15/16.
//  Copyright © 2016 Maxim. All rights reserved.
//

import UIKit

class AdvancedSearchView: UIViewController, AKPickerViewDataSource, AKPickerViewDelegate {

    @IBOutlet weak var economyBtn: ISRadioButton!
    @IBOutlet weak var applyBtn: UIButton!
    @IBOutlet var adultsPicker: AKPickerView!
    @IBOutlet var childrensPicker: AKPickerView!
    @IBOutlet var infantsPicker: AKPickerView!
    
    let adultsTitles = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"] as [String]
    let childrenstitles = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"] as [String]
    let infantsTitles = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"] as [String]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showAnimate()
        pickerViewCustomize()
    }
    
    // MARK: - AKPickerViewDataSource
    
    func numberOfItemsInPickerView(_ pickerView: AKPickerView) -> Int {
        return self.adultsTitles.count 
    }
    
    func pickerView(_ pickerView: AKPickerView, titleForItem item: Int) -> String {
        return self.adultsTitles[item]
    }
    
    func pickerView(_ pickerView: AKPickerView, didSelectItem item: Int) {
        print( self.adultsTitles[item])
        print( self.adultsTitles[item])
        print( self.adultsTitles[item])
    }
    
    @IBAction func applyBtnClose(_ sender: AnyObject) {
        removeAnimate()
    }
    
    @IBAction func closeView(_ sender: UIButton) {
        removeAnimate()
    }
    
    

}


