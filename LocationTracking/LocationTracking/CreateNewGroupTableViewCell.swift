//
//  CreateNewGroupTableViewCell.swift
//  LocationTracking
//
//  Created by Hai Dang Nguyen on 10/16/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit

protocol createGroupDelegate {
    func saveGroup(indexPath:IndexPath)
}

class CreateNewGroupTableViewCell: UITableViewCell {

    @IBOutlet weak var selectedButton: UIButton!
    @IBOutlet weak var memberNameLabel: UILabel!
    @IBOutlet weak var memberLocationLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    var indexPath = IndexPath()
    var delegate: createGroupDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func tappedSelectedMember(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        delegate?.saveGroup(indexPath: indexPath)
    }
    
    func setupCell(contact:Contact) {
        memberNameLabel.text = contact.email
        Common.convertToAddress(latitude: contact.latitude, longitude: contact.longitude, onCompletionHandler: {address in
            self.memberLocationLabel.text = address
        })
    }
}
