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
    
    static func updateProfile(id: String, email: String,name: String, latitude: Double, longitude: Double,onCompletionHandler: @escaping () -> ()) {
        MagicalRecord.save({(localContext : NSManagedObjectContext) in
            var profile = Profile.mr_findFirst(in: localContext)
            if profile == nil {
                profile = Profile.mr_createEntity(in: localContext)
                profile?.id = id
            }
            profile?.name = name
            profile?.email = email
            profile?.latitude = latitude
            profile?.longitude = longitude
        }, completion: { didContext in
            onCompletionHandler()
        })
    }
    
    //MARK: - Location
    static func updateLocationList(id: String, name: String, latitude: Double, longitude: Double,onCompletionHandler: @escaping () -> ()) {
        MagicalRecord.save({(localContext : NSManagedObjectContext) in
            var location = self.getLocation(id: id, contetxt: localContext)
            if location == nil {
                location = LocationEntity.mr_createEntity(in: localContext)
                location?.id = id
            }
            location?.name = name
            location?.latitude = latitude
            location?.longitude = longitude
        }, completion: { didContext in
            onCompletionHandler()
        })
    }
    
    static func getLocation(id : String, contetxt: NSManagedObjectContext?) -> LocationEntity? {
        let currentContext: NSManagedObjectContext?
        
        if contetxt == nil {
            currentContext = NSManagedObjectContext.mr_default()
        } else {
            currentContext = contetxt
        }
        let predicate = NSPredicate(format: "id = %@",id)
        let location = LocationEntity.mr_findFirst(with: predicate, in: currentContext!)
        return location != nil ? location : nil
    }
    
    static func getAllLocationList(context: NSManagedObjectContext?) -> [LocationEntity]! {
        let currentContext: NSManagedObjectContext?
        if context == nil {
            currentContext = NSManagedObjectContext.mr_default()
        } else {
            currentContext = context
        }
        let location = LocationEntity.mr_findAll(in: currentContext!)
        return location != nil ? location as! [LocationEntity]! : []
    }
    
    //MARK: - Contact
    static func saveContact(contactArray : [ContactModel], onCompletion:@escaping (Void) -> Void)  {
        MagicalRecord.save({(localContext : NSManagedObjectContext) in
            for contact in contactArray {
                var newContact = self.getContact(id: contact.id,contetxt: localContext)
                if newContact == nil {
                    newContact = Contact.mr_createEntity(in: localContext)
                }
                newContact?.name = contact.name
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
    
    static func updateContact(id: String,name: String?, latitude: Double?, longitude: Double?,isShare: Int?, onCompletion:@escaping (Void) -> Void)  {
        MagicalRecord.save({(localContext : NSManagedObjectContext) in
            var contact = self.getContact(id: id, contetxt: localContext)
            if contact == nil {
                contact = Contact.mr_createEntity(in: localContext)
                contact?.id = id
            }
            if name != nil {
                contact?.name = name
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
    
    static func updateContactWithEmail(id:String, email: String,name: String, latitude: Double, longitude: Double,isShare: Int?, onCompletion:@escaping (Void) -> Void)  {
        MagicalRecord.save({(localContext : NSManagedObjectContext) in
            var contact = self.getContactWithEmail(email: email, contetxt: localContext)
            if contact == nil {
                contact = Contact.mr_createEntity(in: localContext)
                contact?.email = email
                contact?.id = id
            }
            contact?.latitude = latitude
            contact?.longitude = longitude
            contact?.name = name
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
    
    static func deleteContact(contactId:String, onCompletion:@escaping () -> ()) {
        MagicalRecord.save({(localContext : NSManagedObjectContext) in
            let predicate = NSPredicate(format: "id = %@",contactId)
            Contact.mr_deleteAll(matching: predicate, in: localContext)
        }, completion:{ didContext in
            onCompletion()
        })
    }
    
    //MARK: - Groups
    static func getGroup(id : String, contetxt: NSManagedObjectContext?) -> GroupEntity? {
        let currentContext: NSManagedObjectContext?
        
        if contetxt == nil {
            currentContext = NSManagedObjectContext.mr_default()
        } else {
            currentContext = contetxt
        }
        let predicate = NSPredicate(format: "id = %@",id)
        let group = GroupEntity.mr_findFirst(with: predicate, in: currentContext!)
        return group != nil ? group : nil
    }
    
    static func getAllGroup(context: NSManagedObjectContext?) -> [GroupEntity]! {
        let currentContext: NSManagedObjectContext?
        if context == nil {
            currentContext = NSManagedObjectContext.mr_default()
        } else {
            currentContext = context
        }
        let group = GroupEntity.mr_findAll(in: currentContext!)
        return group != nil ? group as! [GroupEntity]! : []
    }
    
    static func deleteGroup(grouptId:String, onCompletion:@escaping () -> ()) {
        MagicalRecord.save({(localContext : NSManagedObjectContext) in
            let predicate = NSPredicate(format: "id = %@",grouptId)
            GroupEntity.mr_deleteAll(matching: predicate, in: localContext)
        }, completion:{ didContext in
            onCompletion()
        })
    }
    
    static func updateGroup(id: String, name: String?, member: String?, owner: String?, onCompletion:@escaping (Void) -> Void)  {
        MagicalRecord.save({(localContext : NSManagedObjectContext) in
            var group = self.getGroup(id: id, contetxt: localContext)
            if group == nil {
                group = GroupEntity.mr_createEntity(in: localContext)
                group?.id = id
            }
            if name != nil {
                group?.name = name
            }
            if member != nil {
                group?.member = member!
            }
            if owner != nil {
                group?.owner = owner!
            }
        }, completion:{ didContext in
            onCompletion()
        })
    }
    
    static func resetAllData( onCompletion:@escaping () -> ()) {
        MagicalRecord.save({(localContext : NSManagedObjectContext) in
            Contact.mr_truncateAll(in: localContext)
            Profile.mr_truncateAll(in: localContext)
        }, completion:{ didContext in
            onCompletion()
        })
    }
}
