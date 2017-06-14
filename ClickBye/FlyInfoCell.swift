//
//  FlyInfoCell.swift
//  ClickBye
//
//  Created by Maxim  on 11/21/16.
//  Copyright © 2016 Maxim. All rights reserved.
//

import UIKit

class FlyInfoCell: UITableViewCell {

    @IBOutlet weak var backgroundAlpha: UIImageView!
    @IBOutlet weak var flickrImage: UIImageView!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var firstEmoji: UIImageView!
    @IBOutlet weak var secondEmoji: UIImageView!
    @IBOutlet weak var thirdEmoji: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
      backgroundAlpha.image = nil
      flickrImage.image = nil
      placeNameLabel.text = nil
      priceLabel.text = nil
      firstEmoji.image = nil
      secondEmoji.image = nil
      thirdEmoji.image = nil
    }
}
