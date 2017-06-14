//
//  SocialCell.swift
//  ClickBye
//
//  Created by Maxim  on 11/11/16.
//  Copyright © 2016 Maxim. All rights reserved.
//

import UIKit

class SocialCell: UITableViewCell {
    
    static let nib = UINib(nibName: "SocialCell", bundle: nil)
    static let reuseIdentifier = "SocialCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = UITableViewCellSelectionStyle.none
        self.backgroundColor = UIColor.clear
    }
}
