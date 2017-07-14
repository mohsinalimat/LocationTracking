//
//  DatabaseManager.swift
//  LocationTracking
//
//  Created by Nguyen Hai Dang on 6/20/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit
import MagicalRecord
import CoreData
import Foundation

class DatabaseManager: NSObject {

    //MARK: - Profile
    static func getProfile() -> Profile? {
        let profile = Profile.mr_findFirst()
        
        return profile != nil ? profile : nil
    }
    
    static func updateProfile(id: String, email: String, latitude: Double, longitude: Double) {
        MagicalRecord.save({(localContext : NSManagedObjectContext) in
            var profile = Profile.mr_findFirst(in: localContext)
            if profile == nil {
                profile = Profile.mr_createEntity(in: localContext)
            }
            profile?.id = id
            profile?.email = email
            profile?.latitude = latitude
            profile?.longitude = longitude
        })
    }
    
    //MARK: - Contact
    static func updateContact(id: String, email: String, latitude: Double, longitude: Double,isShared: Bool) {
        MagicalRecord.save({(localContext : NSManagedObjectContext) in
            var contact = self.getContact(id: id)
            if contact == nil {
                contact = Contact.mr_createEntity(in: localContext)
            }
            contact?.id = id
            contact?.email = email
            contact?.latitude = latitude
            contact?.longitude = longitude
            contact?.isShare = isShared
        })
    }
    
    static func getContact(id : String) -> Contact? {
        let predicate = NSPredicate(format: "id = %@",id)
        let contact = Contact.mr_findFirst(with: predicate)
        
        return contact != nil ? contact : nil
    }
}
