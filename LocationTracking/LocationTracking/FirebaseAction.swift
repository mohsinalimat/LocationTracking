//
//  FirebaseAction.swift
//  LocationTracking
//
//  Created by Nguyen Hai Dang on 6/17/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit
import Firebase

class FirebaseAction: NSObject {
    
    lazy var ref: FIRDatabaseReference = FIRDatabase.database().reference()

    func initFirebase() {
        FIRApp.configure()
        FIRDatabase.database().reference()
    }
    
    func updateLocation(id: String, lat: Double, long: Double) {
        ref.child(id).child("currentLocations").setValue(["latitude":lat,"longitude":long])
    }
    
    //MARK: USER INFORMATION
    //Create new user to sign up firebase
    func createUser(email: String) -> String{
        var resultRef: FIRDatabaseReference = FIRDatabase.database().reference()

        let userInfoDictionary = ["currentLocations": ["latitude":0,"longitude":0],"email":email] as [String : Any]
        resultRef = ref.childByAutoId()
        resultRef.setValue(userInfoDictionary)
        return resultRef.key
    }
    
    func getProfile(onCompletionHandler: @escaping () -> ()) {
        let profile = DatabaseManager.getProfile()        
        ref.child((profile?.id)!).observe(.value, with: { (snapshot) in
            let snapDict = snapshot.value as? [String : AnyObject] ?? [:]
            self.saveToDatabase(snapDict: snapDict, onCompletionHandler: {_ in
                
            })
        })
    }
    
    //Sign in
    func signInWith(email: String, password: String, completionHandler: @escaping (Bool) -> ()) {
        FIRAuth.auth()?.signIn(withEmail:email, password: password) { (user, error) in
            if error == nil {
                self.searchContactWithEmail(email: email, completionHandler: { array in
                    if array.count > 0 {
                        let newProfile: ContactModel = array.first!
                        
                        //Save profile after login
                        DatabaseManager.updateProfile(id: newProfile.id, email: newProfile.email, latitude: newProfile.latitude, longitude: newProfile.longitude,onCompletionHandler: {_ in
                            for dict in newProfile.contact {
                                
                                self.getInformationForKey(contactId: dict.key, isShare:dict.value as? Int,conCompletionHandler: {_ in
                                    if dict.key == Array(newProfile.contact.keys).last {
                                        completionHandler(true)
                                    }
                                })
                            }
                        })
                    } else {
                        completionHandler(false)
                    }
                })
            } else {
                completionHandler(false)
            }
        }
    }

    //Sign out
    func signOut() -> Bool{
        do{
            try FIRAuth.auth()?.signOut()
            return true
        }catch{
            print("Error while signing out!")
            return false
        }
    }
    
    //MARK: - Contact
    //Search contact to contact List
    func searchContactWithEmail(email: String, completionHandler: @escaping ([ContactModel]) -> ()) {
        ref.queryOrdered(byChild: "email").queryStarting(atValue: email).queryEnding(atValue: email+"\u{f8ff}").observe(.value, with: { snapshot in
            var array = [ContactModel]()
            let snapDic = snapshot.value as? [String:Any]

            for child in snapDic! {
                var allDict = child.value as? [String:Any]
                allDict?["id"] = child.key
                let contactModel = ContactModel()
                contactModel.initContactModel(dict: allDict!)
                array.append(contactModel)
                print(child)
            }
            completionHandler(array)
        })
    }
    
    func getInformationForKey(contactId:String,isShare: Int?,conCompletionHandler: @escaping () -> ()) {
        ref.child(contactId).observe(.value, with: { (snapshot) in
            var snapDict = snapshot.value as? [String : AnyObject] ?? [:]
            snapDict["isShare"] = isShare as AnyObject?
            snapDict["id"] = contactId as AnyObject?
            self.saveToDatabase(snapDict: snapDict, onCompletionHandler: {_ in
                conCompletionHandler()
            })
        })
    }
    
    func requestLocation(toContact:Contact, onCompletetionHandler: @escaping () -> ()) {
        var resultRef: FIRDatabaseReference = FIRDatabase.database().reference()
        let profile = DatabaseManager.getProfile()
        
        //comform to contact id
        resultRef = ref.child((toContact.id)!)
        
        //comform to waiting share property
        resultRef.child("contact").child((profile?.id)!).setValue(3)
        onCompletetionHandler()
    }
    
    func referentToContact(onCompletionHandler: @escaping () -> ()) {
        ref.observe(.childChanged, with: { (snapshot) in
            let snapDict = snapshot.value as? [String : AnyObject] ?? [:]
            self.saveToDatabase(snapDict: snapDict, onCompletionHandler: {_ in
                onCompletionHandler()
            })
        })
    }
    
    //MARK: - Save database
    func saveToDatabase(snapDict: [String : AnyObject], onCompletionHandler: @escaping () -> ()) {
        var id = ""
        
        if snapDict["id"] != nil {
            id = snapDict["id"] as! String
        }
        if snapDict["email"] != nil {
            let email = snapDict["email"] as! String
            let currentLocationDictionary = snapDict["currentLocations"] as! [String: Any]
            let profile = DatabaseManager.getProfile()
            if profile?.email == email {
                DatabaseManager.updateProfile(id: (profile?.id)!, email: email, latitude: currentLocationDictionary["latitude"] as! Double, longitude: currentLocationDictionary["longitude"] as! Double, onCompletionHandler: {_ in
                    
                    if snapDict["contact"] != nil {
                        let contactDictionary = snapDict["contact"] as! [String:Any]
                        for dict in contactDictionary {
                            let isShare = (dict.value as! NSNumber).intValue
                            DatabaseManager.updateContact(id: dict.key, latitude: nil, longitude: nil, isShare: isShare, onCompletion: {
                                if dict.key == Array(contactDictionary.keys).last {
                                    onCompletionHandler()
                                }
                            })
                        }
                    }
                })
            } else {
                //changed contact
                var isShare:Int? = nil
                if snapDict["isShare"] != nil {
                    isShare = snapDict["isShare"] as? Int
                }
                
                DatabaseManager.updateContactWithEmail(id:id,email: email, latitude: currentLocationDictionary["latitude"] as! Double, longitude: currentLocationDictionary["longitude"] as! Double, isShare: isShare, onCompletion: {
                    onCompletionHandler()
                })
            }
            
        }
    }
}
