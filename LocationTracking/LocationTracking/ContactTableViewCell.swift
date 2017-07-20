//
//  FriendListTableViewCell.swift
//  LocationTracking
//
//  Created by Nguyen Hai Dang on 6/17/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var currentLocationLabel: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var requestLocation: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    //MARK: - Action
    @IBAction func tappedRequestLocation(_ sender: UIButton) {
    }
    
    //MARK: - Setup Cell
    func setupCell(contact:Contact) {
        userNameLabel.text = contact.email
        currentLocationLabel.text = String(contact.latitude)
        if contact.isShare == Int16(ShareStatus.kNotYetShared.rawValue) {
            //Not yet shared location
            requestLocation.isHidden = false
            currentLocationLabel.isHidden = true
        } else if contact.isShare == Int16(ShareStatus.kShared.rawValue) {
            //Shared location
            requestLocation.isHidden = true
            currentLocationLabel.isHidden = false
        } else if contact.isShare == Int16(ShareStatus.kSharedWaiting.rawValue) {
            //Shared location
            requestLocation.isHidden = true
            currentLocationLabel.isHidden = false
        }
    }
}
