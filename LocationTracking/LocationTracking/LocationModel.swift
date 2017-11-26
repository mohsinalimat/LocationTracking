//
//  LocationModel.swift
//  LocationTracking
//
//  Created by Thuy Phan on 11/26/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit

class LocationModel: NSObject {
    var latitude: Double = 0
    var longitude: Double = 0
    var id: String = ""
    var name: String = ""
    
    func initLocationModel(dict: [String:Any]) {
        if dict["name"] != nil {
            self.name = dict["name"] as! String
        }
        if dict["id"] != nil {
            self.id = dict["id"] as! String
        }

        if dict["longitude"] != nil {
            self.longitude = dict["longitude"] as! Double
        }
        if dict["latitude"] != nil {
            self.latitude = dict["latitude"] as! Double
        }
    }
}
