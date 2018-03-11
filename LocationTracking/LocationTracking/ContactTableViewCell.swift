//
//  FriendListTableViewCell.swift
//  LocationTracking
//
//  Created by Nguyen Hai Dang on 6/17/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit

protocol ContactTableViewCellDelegate {
    func requestLocation(contact: ContactModel)
    func shareLocation(contact: ContactModel)
}

class ContactTableViewCell: UITableViewCell {
    @IBOutlet weak var deleteCellButton: UIButton!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var currentLocationLabel: UILabel!
    @IBOutlet weak var shareLocationButton: UIButton!
    @IBOutlet weak var requestLocationButton: UIButton!
    var contactObject: ContactModel?
    var indexPath = IndexPath()
    
    var delegate: ContactTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        shareLocationButton.customBorder(radius: 3,color: .clear)
        requestLocationButton.customBorder(radius: 3,color: .clear)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    //MARK: - Action
    @IBAction func tappedRequestLocation(_ sender: UIButton) {
        if contactObject != nil {
            delegate?.requestLocation(contact: contactObject!)
        }
    }
    
    @IBAction func tappedShareLocation(_ sender: UIButton) {
        if contactObject != nil {
            delegate?.shareLocation(contact: contactObject!)
        }
    }
    
    //MARK: - Setup Cell
    func setupCell(contact:ContactModel) {
        contactObject = contact
        if contact.name != nil {
            userNameLabel.text = contact.name
        } else {
            userNameLabel.text = contact.email
        }
        currentLocationLabel.text = "Loading,please wait a moment."
        
        if contact.isShare == Int16(ShareStatus.kShared.rawValue) {
            //Shared location
            requestLocationButton.isHidden = true
            shareLocationButton.isHidden = true
            currentLocationLabel.isHidden = false
            Common.convertToAddress(latitude: contact.latitude, longitude: contact.longitude, onCompletionHandler: {address in
                self.currentLocationLabel.text = address
            })
        } else if contact.isShare == Int16(ShareStatus.kwaitingShared.rawValue) {
            //Shared location
            requestLocationButton.isHidden = true
            shareLocationButton.isHidden = true
            currentLocationLabel.isHidden = false
            currentLocationLabel.text = "Waiting to share location"
        } else if contact.isShare == Int16(ShareStatus.kRequestShare.rawValue) {
            //Users request share location
            requestLocationButton.isHidden = true
            currentLocationLabel.isHidden = true
            shareLocationButton.isHidden = false
        } else if contact.isShare == Int16(ShareStatus.kNotYetShared.rawValue) {
            //Users request share location
            requestLocationButton.isHidden = false
            shareLocationButton.isHidden = true
            currentLocationLabel.isHidden = true
        }
    }
    
    func setupGroupCell(group: GroupModel,memberCount: NSInteger) {
        userNameLabel.text = group.name
        currentLocationLabel.isHidden = false
        requestLocationButton.isHidden = true
        shareLocationButton.isHidden = true
        let ownerString = "Owner:"
        let memberArray = group.member?.split(separator: ",")
        let memberCount = "Members: " + String(describing: (memberArray?.count)!) + "\n"
        
        if group.owner == app_delegate.profile.id {
            currentLocationLabel.text = memberCount + ownerString + app_delegate.profile.name
        } else {
//            let owner = DatabaseManager.getContact(id: group.owner!, contetxt: nil)
//            if owner != nil {
//                currentLocationLabel.text = memberCount + ownerString + (owner?.name!)!
//            } else {
//                currentLocationLabel.text = memberCount + ""
//            }
        }
    }
    
    func setupLocationCell(location: LocationModel) {
        userNameLabel.text = location.name
        currentLocationLabel.isHidden = false
        requestLocationButton.isHidden = true
        shareLocationButton.isHidden = true
        
        let locationString = "Lat: " + String(describing: location.latitude) + "\n" + "Long:" + String(describing: location.longitude)
        currentLocationLabel.text = locationString
    }
}
