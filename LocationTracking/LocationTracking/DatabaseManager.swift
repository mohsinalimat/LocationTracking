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
    static func saveContact(contactArray : [ContactModel], onCompletion:@escaping (Void) -> Void)  {
        MagicalRecord.save({(localContext : NSManagedObjectContext) in
            for contact in contactArray {
                var newContact = self.getContact(id: contact.id,contetxt: localContext)
                if newContact == nil {
                    newContact = Contact.mr_createEntity(in: localContext)
                }
                newContact?.id = contact.id
                newContact?.email = contact.email
                newContact?.latitude = contact.latitude
                newContact?.longitude = contact.longitude
                newContact?.isShare = Int16(contact.isShare)
                newContact?.waitingShare = contact.waitingShare
            }
        }, completion:{ didContext in
            onCompletion()
        })
    }
    
    static func updateContact(id: String, latitude: Double, longitude: Double,isShare: Int, onCompletion:@escaping (Void) -> Void)  {
        MagicalRecord.save({(localContext : NSManagedObjectContext) in
                var contact = self.getContact(id: id, contetxt: localContext)
                if contact == nil {
                    contact = Contact.mr_createEntity(in: localContext)
                }
                contact?.latitude = latitude
                contact?.longitude = longitude
                contact?.isShare = Int16(isShare)
        }, completion:{ didContext in
            onCompletion()
        })
    }
    
    static func getContact(id : String, contetxt: NSManagedObjectContext?) -> Contact? {
        let currentContext: NSManagedObjectContext?
        
        if contetxt == nil {
            currentContext = NSManagedObjectContext.mr_default()
        } else {
            currentContext = contetxt
        }
        let predicate = NSPredicate(format: "id = %@",id)
        let contact = Contact.mr_findFirst(with: predicate, in: currentContext!)
        return contact != nil ? contact : nil
    }
    
    static func getAllContact() -> [Contact]! {
        let contact = Contact.mr_findAll()
        return contact != nil ? contact as! [Contact]! : []
    }
}
