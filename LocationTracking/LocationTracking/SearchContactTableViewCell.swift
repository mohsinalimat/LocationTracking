//
//  SearchContactTableViewCell.swift
//  LocationTracking
//
//  Created by Nguyen Hai Dang on 6/22/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//



import UIKit

protocol SearchContactDelegate {
    func SaveContact(indexPath:IndexPath)
    func unSelected(indexPath:IndexPath)
}

class SearchContactTableViewCell : UITableViewCell {
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var selectionButton: UIButton!
    var indexPath = IndexPath()
    
    var delegate: SearchContactDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    //MARK: - Function
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: - Action
    @IBAction func tappedSelectedContact(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            delegate?.SaveContact(indexPath: indexPath)
        } else {
            delegate?.unSelected(indexPath: indexPath)
        }
    }
    
    func setupCell(contact:ContactModel) {
        emailLabel.text = contact.name
        Common.convertToAddress(latitude: contact.latitude, longitude: contact.longitude, onCompletionHandler: {address in
            self.locationLabel.text = address
        })
    }
}
