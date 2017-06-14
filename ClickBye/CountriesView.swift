//
//  CountriesView.swift
//  ClickBye
//
//  Created by Maxim  on 12/4/16.
//  Copyright © 2016 Maxim. All rights reserved.
//

import UIKit
import DropDown

class CountriesView: UIViewController {
    
    
    @IBOutlet weak var dropBtn: UIBarButtonItem!
    @IBOutlet weak var searchBarHeight: NSLayoutConstraint!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let dropMemu = DropDown()
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeDropDown()
        searchBarHeight.constant = 0
        searchBar.barTintColor = UIColor.red
        self.navigationController?.navigationBar.barTintColor = Theme.Colors.brightRed   
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navBarCustomize()
    }

    @IBAction func dropDown(_ sender: UIBarButtonItem) {
        
        dropMemu.show()
    }
    
    func customizeDropDown() {
        dropMemu.anchorView = dropBtn
        dropMemu.dataSource = ["Wish List", "Share"]
        
        dropMemu.selectionAction = { [unowned self] (index, item) in
            switch index {
            case 0: self.barAnimateExpand()
            case 1: self.barAnimateCollapse()
            default:
                break
            }
        }
    }
    
    //TODO: FIX THIS!
    func barAnimateExpand() {
        UIView.animate(withDuration: 0.5, animations: {
            self.searchBarHeight.constant = 44
        })
    }
    
    func barAnimateCollapse() {
        UIView.animate(withDuration: 0.5, animations: {
            self.searchBarHeight.constant = 0
        })
    }
    
    func navBarCustomize() {
        
    }

}
