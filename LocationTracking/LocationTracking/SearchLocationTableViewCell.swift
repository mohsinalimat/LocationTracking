//
//  SearchLocationTableViewCell.swift
//  LocationTracking
//
//  Created by Thuy Phan on 11/26/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit

protocol SearchLocationDelegate {
    func SaveLocation(indexPath:IndexPath)
}

class SearchLocationTableViewCell: UITableViewCell {

    @IBOutlet weak var selectedButton: UIButton!
    @IBOutlet weak var locationIconImageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationNameLabel: UILabel!
    var delegate: SearchLocationDelegate?
    var indexPath = IndexPath()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func tappedSelectedLocation(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        delegate?.SaveLocation(indexPath: indexPath)
    }
    
    func setupCell(location: LocationModel) {
        locationNameLabel.text = location.name
        self.locationLabel.text = "Lat: " + String(location.latitude) + "\n" + "Long: " + String(location.longitude)
    }
}
