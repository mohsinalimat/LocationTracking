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
    
    //MARK: - Setup Cell
    func setupCell(contact:ContactModel) {
        contactObject = contact
        userNameLabel.text = contact.name
        currentLocationLabel.text = "Loading..."
        let status = app_delegate.profile.contact[contact.id] as! Int
        
        switch status {
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
        let ownerString = "Owner:"
        let memberArray = group.member.split(separator: ",")
        let memberCount = "Members: " + String(describing: memberArray.count) + "\n"
        
        currentLocationLabel.text = memberCount + ownerString + group.owner
    }
    
    func setupLocationCell(location: LocationModel) {
        userNameLabel.text = location.name
        currentLocationLabel.isHidden = false
        shareLocationButton.isHidden = true
        
        let locationString = "Lat: " + String(describing: location.latitude) + "\n" + "Long:" + String(describing: location.longitude)
        currentLocationLabel.text = locationString
    }
}
