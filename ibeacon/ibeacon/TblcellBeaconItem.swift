//
//  TblcellBeaconItem.swift
//  ibeacon
//
//  Created by Surattikorn Chumkaew on 7/6/2561 BE.
//  Copyright © 2561 example. All rights reserved.
//

import UIKit

class TblcellBeaconItem: UITableViewCell {

    @IBOutlet weak var txtMajorMinor: UILabel!
    @IBOutlet weak var txtRange: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
