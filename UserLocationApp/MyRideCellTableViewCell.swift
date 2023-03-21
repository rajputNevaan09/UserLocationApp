//
//  MyRideCellTableViewCell.swift
//  UserLocationApp
//
//  Created by Bhagwan Rajput on 21/03/23.
//

import UIKit

class MyRideCellTableViewCell: UITableViewCell {

    @IBOutlet var lblNumOfRide: UILabel!
    @IBOutlet var lblDateRide: UILabel!
    @IBOutlet var lblDistance: UILabel!
    @IBOutlet var lblTimeTaken: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
