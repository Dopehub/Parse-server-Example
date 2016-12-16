//
//  DeviceInfoCell.swift
//  ParseStarterProject-Swift
//
//  Created by Imad Ajallal on 12/15/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class DeviceInfoCell: UITableViewCell {
	
	@IBOutlet weak var deviceName: UILabel!
	@IBOutlet weak var cellTitle: UILabel!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
