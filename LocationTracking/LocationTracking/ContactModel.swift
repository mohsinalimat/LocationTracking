//
//  ContactModel.swift
//  LocationTracking
//
//  Created by Nguyen Hai Dang on 6/22/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit

class ContactModel: NSObject {
    var email: String = ""
    var name: String = ""
    var latitude: Double = 0
    var longitude: Double = 0
    var id: String = ""
    var isShare : Int = 1
    var contact = [String: Any]()
    var group = [String]()
    var locationList = [String: Any]()
    
    func initContactModel(dict: [String:Any]) {
        if dict["email"] != nil {
            self.email = dict["email"] as! String
        }
        if dict["id"] != nil {
            self.id = dict["id"] as! String
        }
        if dict["name"] != nil {
            self.name = dict["name"] as! String
        }
        if dict["currentLocations"] != nil {
            let locationDictionary = dict["currentLocations"] as! [String:Any]
            if locationDictionary["longitude"] != nil {
                self.longitude = locationDictionary["longitude"] as! Double
            }
            if locationDictionary["latitude"] != nil {
                self.latitude = locationDictionary["latitude"] as! Double
            }
        }

        if dict["contact"] != nil {
            contact = dict["contact"] as! [String: Any]
        }
        if dict["group"] != nil {
            group = dict["group"] as! [String]
        }
        if dict["locationList"] != nil {
            locationList = dict["locationList"] as! [String: Any]
        }
        
        if app_delegate.profile.contact[self.id] != nil {
            isShare = app_delegate.profile.contact[self.id] as! Int
        }
    }
}
