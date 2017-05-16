//
//  ShopTableViewCell.swift
//  MadridShopping
//
//  Created by JJLZ on 5/17/17.
//  Copyright © 2017 ESoft. All rights reserved.
//

import UIKit

class ShopTableViewCell: UITableViewCell {
    
    // MARK: IBOutlet's
    @IBOutlet weak var ivImage: UIImageView!
    @IBOutlet weak var lblName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
