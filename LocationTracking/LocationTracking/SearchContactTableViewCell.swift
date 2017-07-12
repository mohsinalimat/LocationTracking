//
//  SearchContactTableViewCell.swift
//  LocationTracking
//
//  Created by Nguyen Hai Dang on 6/22/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit

class SearchContactTableViewCell: UITableViewCell {

    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var selectionButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    //MARK: - Action
    @IBAction func tappedSelectedContact(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    //MARK: - Function
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setupCell(contact:ContactModel) {
        emailLabel.text = contact.email
        locationLabel.text = "Latitude:" + String(contact.latitude) + "    " + "Longitude:" + String(contact.longitude)
    }
}
