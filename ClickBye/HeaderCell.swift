//
//  HeaderCell.swift
//  ClickBye
//
//  Created by Maxim  on 11/10/16.
//  Copyright © 2016 Maxim. All rights reserved.
//

import UIKit

class HeaderCell: UITableViewCell {
    
    static let nib = UINib(nibName: "HeaderCell", bundle: nil)
    static let reuseIdentifier = "HeaderCell"
    
    @IBOutlet weak var profileImageView: UIImageView?
    @IBOutlet weak var userNameLabel: UILabel?
    @IBOutlet weak var dummyTextLabel: UILabel?
    @IBOutlet weak var userLocationLabel: UILabel?
    @IBOutlet weak var locationImageView: UIImageView?
    
    var profileAvatarImage: UIImage? {
        didSet {
            self.profileImageView?.image = profileAvatarImage
        }
    }
    var userNameString: String? {
        didSet {
            self.userNameLabel?.text = userNameString
        }
    }
    var userLocationString: String? {
        didSet {
            self.userLocationLabel?.text = userLocationString
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = UITableViewCellSelectionStyle.none
        self.backgroundColor = UIColor.clear
        
        self.profileImageView?.clipsToBounds = true
        self.profileImageView?.layer.borderWidth = 2.0
        self.profileImageView?.layer.borderColor = UIColor.white.cgColor
        self.profileImageView?.layer.cornerRadius = 30.0
    }
}
