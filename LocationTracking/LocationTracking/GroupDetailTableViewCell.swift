//
//  GroupDetailTableViewCell.swift
//  LocationTracking
//
//  Created by Hai Dang Nguyen on 3/29/18.
//  Copyright © 2018 Nguyen Hai Dang. All rights reserved.
//

import UIKit

class GroupDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setupCell(contact: ContactModel) {
        nameLabel.text = contact.name
        Common.convertToAddress(latitude: contact.latitude, longitude: contact.longitude, onCompletionHandler: {address in
            self.locationLabel.text = address
        })
    }
}
