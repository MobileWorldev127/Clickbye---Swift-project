//
//  SideMenu.swift
//  ClickBye
//
//  Created by Maxim  on 11/10/16.
//  Copyright © 2016 Maxim. All rights reserved.
//

import UIKit
import SideMenu

class SideMenu: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sideMenu()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            return 180
        }
        else if indexPath.row == 1 {
            return 60
        }
        else if indexPath.row == 2 {
            return 60
        }
        else if indexPath.row == 3 {
            return 60
        }
        else if indexPath.row == 4 {
            return 60
        }
        else {
            return 100
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return self.headerTableViewCell(tableView: tableView, cellForRowAt: indexPath)
        } else if indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 4 {
            return self.sideBarTableViewCell(tableView: tableView, cellForRowAt: indexPath)
        } else if indexPath.row == 3 {
            return self.socialTableViewCell(tableView: tableView, cellForRowAt: indexPath)
        }
        
        return UITableViewCell()
    }
    
    func headerTableViewCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: HeaderCell.reuseIdentifier, for: indexPath) as? HeaderCell {
            if let user = User.currentUser {
                cell.userNameString = user.name
                cell.profileAvatarImage = user.profileImage
                cell.userLocationString = user.location
            }

            return cell
        }
        
        return UITableViewCell()
    }
    
    //MARK: UITableViewCell Helpers
    
    func sideBarTableViewCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: SideBarTableViewCell.reuseIdentifier, for: indexPath) as? SideBarTableViewCell {
            let isTraveller = User.currentUser == nil
            var title = isTraveller ? "LOG IN / SIGN UP" : "INSPIRATION"
            var image = isTraveller ? UIImage(named: "logout") : UIImage(named: "binoculars")
            
            if indexPath.row == 2 {
                title = isTraveller ? "INSPIRATION" : "WISHLIST"
                image = isTraveller ? UIImage(named: "binoculars") : UIImage(named: "earth")
            } else if indexPath.row == 4 {
                title = isTraveller ? "INVITE FRIENDS" : "LOGOUT"
                image = isTraveller ? UIImage(named: "share-variant") : UIImage(named: "logout")
            }
            
            cell.cellTitle = title
            cell.cellImage = image
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func socialTableViewCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: SocialCell.reuseIdentifier, for: indexPath) as? SocialCell {
            return cell
        }
        
        return UITableViewCell()
    }
    
    //MARK: ConfigureUI
    
    func sideMenu() {
        let isTraveller = User.currentUser == nil
        let tableViewBackgroundImage = isTraveller ? UIImage(named: "10") : UIImage(named: "11")
        let imageView = UIImageView(image: tableViewBackgroundImage)
        
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = UIColor.blue.withAlphaComponent(0.2)
        
        tableView.separatorStyle = .none
        tableView.backgroundView = imageView
        tableView.alwaysBounceVertical = false
        tableView.register(SideBarTableViewCell.nib, forCellReuseIdentifier: SideBarTableViewCell.reuseIdentifier)
        tableView.register(SocialCell.nib, forCellReuseIdentifier: SocialCell.reuseIdentifier)
        tableView.register(HeaderCell.nib, forCellReuseIdentifier: HeaderCell.reuseIdentifier)
        
        SideMenuManager.menuWidth = 300
        SideMenuManager.menuPresentMode = .viewSlideInOut
        SideMenuManager.menuAllowPushOfSameClassTwice = false
        SideMenuManager.menuAnimationBackgroundColor = UIColor.clear
    }
}
