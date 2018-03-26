//
//  FriendListTableViewCell.swift
//  LocationTracking
//
//  Created by Nguyen Hai Dang on 6/17/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit

protocol ContactTableViewCellDelegate {
    func shareLocation(contact: ContactModel)
}

class ContactTableViewCell: UITableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var currentLocationLabel: UILabel!
    @IBOutlet weak var shareLocationButton: UIButton!
    @IBOutlet weak var informationButton: UIButton!
    var contactObject: ContactModel?
    var indexPath = IndexPath()
    
    var delegate: ContactTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        shareLocationButton.customBorder(radius: 3,color: .clear)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    //MARK: - Action
    @IBAction func tappedShareLocation(_ sender: UIButton) {
        if contactObject != nil {
            delegate?.shareLocation(contact: contactObject!)
        }
    }
    
    @IBAction func tappedShowInformation(_ sender: UIButton) {
    }
    
    //MARK: - Setup Cell
    func setupCell(contact:ContactModel) {
        contactObject = contact
        userNameLabel.text = contact.name
        currentLocationLabel.text = "Loading..."
        guard let status = app_delegate.profile.contact[contact.id] else {
            return
        }
        
        switch status as! Int {
        case kRequested:
            //I requested
            shareLocationButton.isHidden = true
            currentLocationLabel.isHidden = false
            currentLocationLabel.text = "Waiting to share location"
            break
        case kRequestedToMe:
            //Requested to me
            currentLocationLabel.isHidden = true
            shareLocationButton.isHidden = false
            
            break
        default:
            //Shared location with me
            shareLocationButton.isHidden = true
            currentLocationLabel.isHidden = false
            Common.convertToAddress(latitude: contact.latitude, longitude: contact.longitude, onCompletionHandler: {address in
                self.currentLocationLabel.text = address
            })
            break
        }
    }
    
    func setupGroupCell(group: GroupModel,memberCount: NSInteger) {
        userNameLabel.text = group.name
        currentLocationLabel.isHidden = false
        shareLocationButton.isHidden = true
        let ownerString = "Owner:  "
        let memberCount = "Members:  " + String(describing: group.member.count) + "\n"
        
        if app_delegate.profile.id == group.owner {
            currentLocationLabel.text = memberCount + ownerString + "me"
        } else {
            let contact = app_delegate.contactArray.filter{$0.id == group.owner}.first
            if contact != nil {
                currentLocationLabel.text = memberCount + ownerString + (contact?.name)!
            }
        }
    }
    
    func setupLocationCell(location: LocationModel) {
        userNameLabel.text = location.name
        currentLocationLabel.isHidden = false
        shareLocationButton.isHidden = true
        
        let locationString = "Latitude: " + String(describing: location.latitude) + "\n" + "Longitude:" + String(describing: location.longitude)
        currentLocationLabel.text = locationString
    }
}
