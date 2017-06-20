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

    static func getProfile() -> Profile? {
        let profile = Profile.mr_findFirst()
        
        return profile != nil ? profile : nil
    }
    
    static func updateProfile(id:String, userName: String, latitude: Double, longitude: Double) {
        MagicalRecord.save({(localContext : NSManagedObjectContext) in
            var profile = Profile.mr_findFirst(in: localContext)
            if profile == nil {
                profile = Profile.mr_createEntity(in: localContext)
            }
            profile?.id = id
            profile?.userName = userName
            profile?.latitude = latitude
            profile?.longitude = longitude
        })
    }
}
