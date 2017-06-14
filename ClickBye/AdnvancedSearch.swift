//
//  AdnvancedSearch.swift
//  ClickBye
//
//  Created by Maxim  on 12/18/16.
//  Copyright © 2016 Maxim. All rights reserved.
//

import Foundation
import UIKit

extension AdvancedSearchView {
    
    
    
    func pickerViewCustomize() {
        
        self.adultsPicker.delegate = self
        self.adultsPicker.dataSource = self
        self.adultsPicker.pickerViewStyle = .wheel
        self.adultsPicker.maskDisabled = false
        self.adultsPicker.interitemSpacing = 20
        self.adultsPicker.viewDepth = 1000
        self.adultsPicker.font = UIFont(name: "HelveticaNeue-Light", size: 20)!
        self.adultsPicker.highlightedFont = UIFont(name: "HelveticaNeue", size: 20)!
        self.adultsPicker.reloadData()
        
        self.childrensPicker.delegate = self
        self.childrensPicker.dataSource = self
        self.childrensPicker.pickerViewStyle = .wheel
        self.childrensPicker.maskDisabled = false
        self.childrensPicker.interitemSpacing = 20
        self.childrensPicker.viewDepth = 1000
        self.childrensPicker.font = UIFont(name: "HelveticaNeue-Light", size: 20)!
        self.childrensPicker.highlightedFont = UIFont(name: "HelveticaNeue", size: 20)!
        self.childrensPicker.reloadData()
        
        self.infantsPicker.delegate = self
        self.infantsPicker.dataSource = self
        self.infantsPicker.pickerViewStyle = .wheel
        self.infantsPicker.maskDisabled = false
        self.infantsPicker.interitemSpacing = 20
        self.infantsPicker.viewDepth = 1000
        self.infantsPicker.font = UIFont(name: "HelveticaNeue-Light", size: 20)!
        self.infantsPicker.highlightedFont = UIFont(name: "HelveticaNeue", size: 20)!
        self.infantsPicker.reloadData()

    }
    
    func showAnimate() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.view.transform =  CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    func removeAnimate() {
        
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
            }, completion: {(finished : Bool) in
                if (finished) {
                    self.view.removeFromSuperview()
                }
        })
    }

    
    
    
    
    
    
    
    
    
    
    
    
}
