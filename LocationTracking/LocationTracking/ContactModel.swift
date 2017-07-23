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
    var latitude: Double = 0
    var longitude: Double = 0
    var id: String = ""
    var isShare : Int = 0
    var contact = [String: Any]()
    
    func initContactModel(dict: [String:Any]) {
        if dict["email"] != nil {
            self.email = dict["email"] as! String
        }
        if dict["id"] != nil {
            self.id = dict["id"] as! String
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
        if dict["shared"] != nil {
            let profile = DatabaseManager.getProfile()
            let shareList = dict["shared"] as! String
            
            if shareList.contains((profile?.id)!) {
                //This contact shared location with user
                isShare = ShareStatus.kShared.rawValue
                return
            }
        }
        if dict["contact"] != nil {
            contact = dict["contact"] as! [String: Any]
        }
        isShare = ShareStatus.kNotYetShared.rawValue
    }
}
