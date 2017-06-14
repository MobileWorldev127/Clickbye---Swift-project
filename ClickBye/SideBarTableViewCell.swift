//
//  DummyCell.swift
//  ClickBye
//
//  Created by Maxim  on 11/11/16.
//  Copyright © 2016 Maxim. All rights reserved.
//

import UIKit

class SideBarTableViewCell: UITableViewCell {
    
    static let nib = UINib(nibName: "SideBarTableViewCell", bundle: nil)
    static let reuseIdentifier = "SideBarTableViewCell"
    
    @IBOutlet weak var descriptionImageView: UIImageView?
    @IBOutlet weak var titleLabel: UILabel?

    var cellImage: UIImage? {
        didSet {
            self.descriptionImageView?.image = cellImage
        }
    }
    
    var cellTitle: String? {
        didSet {
            self.titleLabel?.text = self.cellTitle
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = UITableViewCellSelectionStyle.none
        self.backgroundColor = UIColor.clear
    }
}
