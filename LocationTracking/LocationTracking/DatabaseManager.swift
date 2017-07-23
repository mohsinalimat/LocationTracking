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
    
    static func updateProfile(id: String, email: String, latitude: Double, longitude: Double,onCompletionHandler: @escaping () -> ()) {
        MagicalRecord.save({(localContext : NSManagedObjectContext) in
            var profile = Profile.mr_findFirst(in: localContext)
            if profile == nil {
                profile = Profile.mr_createEntity(in: localContext)
                profile?.id = id
            }
            profile?.email = email
            profile?.latitude = latitude
            profile?.longitude = longitude
        }, completion: { didContext in
            onCompletionHandler()
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
            }
        }, completion:{ didContext in
            onCompletion()
        })
    }
    
    static func updateContact(id: String, latitude: Double?, longitude: Double?,isShare: Int?, onCompletion:@escaping (Void) -> Void)  {
        MagicalRecord.save({(localContext : NSManagedObjectContext) in
            var contact = self.getContact(id: id, contetxt: localContext)
            if contact == nil {
                contact = Contact.mr_createEntity(in: localContext)
                contact?.id = id
            }
            if latitude != nil {
                contact?.latitude = latitude!
            }
            if longitude != nil {
                contact?.longitude = longitude!
            }
            if isShare != nil {
                contact?.isShare = Int16(isShare!)
            }
        }, completion:{ didContext in
            onCompletion()
        })
    }
    
    static func updateContactWithEmail(id:String, email: String, latitude: Double, longitude: Double,isShare: Int?, onCompletion:@escaping (Void) -> Void)  {
        MagicalRecord.save({(localContext : NSManagedObjectContext) in
            var contact = self.getContactWithEmail(email: email, contetxt: localContext)
            if contact == nil {
                contact = Contact.mr_createEntity(in: localContext)
                contact?.email = email
                contact?.id = id
            }
            contact?.latitude = latitude
            contact?.longitude = longitude
            if isShare != nil {
                contact?.isShare = Int16(isShare!)
            }
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
    
    static func getContactWithEmail(email : String, contetxt: NSManagedObjectContext?) -> Contact? {
        let currentContext: NSManagedObjectContext?

        if contetxt == nil {
            currentContext = NSManagedObjectContext.mr_default()
        } else {
            currentContext = contetxt
        }
        let predicate = NSPredicate(format: "email = %@",email)
        let contact = Contact.mr_findFirst(with: predicate, in: currentContext!)
        return contact != nil ? contact : nil
    }
    
    static func getRequestToMeContact(contetxt: NSManagedObjectContext?) -> [Contact]! {
        let currentContext: NSManagedObjectContext?
        let profile = DatabaseManager.getProfile()

        if contetxt == nil {
            currentContext = NSManagedObjectContext.mr_default()
        } else {
            currentContext = contetxt
        }
        let predicate1 = NSPredicate(format: "isShare = %i",ShareStatus.kRequestShare.rawValue)
        let predicate2 = NSPredicate(format: "id != %@",(profile?.id)!)
        let filter = NSCompoundPredicate.init(andPredicateWithSubpredicates: [predicate1,predicate2])

        let contact = Contact.mr_findAll(with: filter, in: currentContext!)
        return contact != nil ? contact as! [Contact]! : []
    }
    
    static func getContactSharedLocation(contetxt: NSManagedObjectContext?) -> [Contact]! {
        let currentContext: NSManagedObjectContext?
        let profile = DatabaseManager.getProfile()

        if contetxt == nil {
            currentContext = NSManagedObjectContext.mr_default()
        } else {
            currentContext = contetxt
        }
        let predicate1 = NSPredicate(format: "isShare != %i",ShareStatus.kRequestShare.rawValue)
        let predicate2 = NSPredicate(format: "id != %@",(profile?.id)!)
        let filter = NSCompoundPredicate.init(andPredicateWithSubpredicates: [predicate1,predicate2])

        let contact = Contact.mr_findAll(with: filter, in: currentContext!)
        return contact != nil ? contact as! [Contact]! : []
    }
    
    static func getAllContact() -> [Contact]! {
        let contact = Contact.mr_findAll()
        return contact != nil ? contact as! [Contact]! : []
    }
}
