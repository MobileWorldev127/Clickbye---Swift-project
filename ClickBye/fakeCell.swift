//
//  fakeCell.swift
//  ClickBye
//
//  Created by Maxim  on 1/18/17.
//  Copyright © 2017 Maxim. All rights reserved.
//

import UIKit

class fakeCell: UITableViewCell {
    
    
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var InfoLabel: UILabel!
    @IBOutlet weak var airLineLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
}
