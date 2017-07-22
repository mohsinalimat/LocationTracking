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
    
    //Sign in
    func signInWith(email: String, password: String, completionHandler: @escaping (Bool) -> ()) {
        FIRAuth.auth()?.signIn(withEmail:email, password: password) { (user, error) in
            let profile = DatabaseManager.getProfile()
            if profile == nil {
                self.searchContactWithEmail(email: email, completionHandler: { array in
                    if array.count > 0 {
                        let profile: ContactModel = array.first!
                        DatabaseManager.updateProfile(id: profile.id, email: profile.email, latitude: profile.latitude, longitude: profile.longitude)
                        completionHandler(true)
                    } else {
                        completionHandler(false)
                    }
                })
            } else {
                if error == nil {
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
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
    
    func requestLocation(toContact:Contact, onCompletetionHandler: @escaping () -> ()) {
        var resultRef: FIRDatabaseReference = FIRDatabase.database().reference()
        let profile = DatabaseManager.getProfile()
        //get old waiting share
        let waitingShare = toContact.waitingShare == nil ? "" : toContact.waitingShare!
        
        //add new contact to waiting share list
        let newWaitingShare = waitingShare + (profile?.id)!
        
        //comform to contact id
        resultRef = ref.child((toContact.id)!)
        
        //comform to waiting share property
        resultRef.child("waitingShare").setValue(newWaitingShare)
        onCompletetionHandler()
    }
    
    func referentToContact(contactId:String, onCompletionHandler: @escaping () -> ()) {
        ref.observe(.childChanged, with: { (snapshot) in
            let snapDict = snapshot.value as? [String : AnyObject] ?? [:]
            var isShared = ShareStatus.kNotYetShared
            if snapDict["Shared"] != nil {
                let shared = snapDict["Shared"] as! String
                let profile = DatabaseManager.getProfile()
                if shared.contains((profile?.id)!) {
                    isShared = ShareStatus.kShared
                } else if snapDict["WaitingShare"] != nil {
                    let waitingShare = snapDict["WaitingShare"] as! String
                    if waitingShare.contains((profile?.id)!) {
                        isShared = ShareStatus.kwaitingShared
                    }
                }
            }
            let currentLocationDictionary = snapDict["currentLocations"] as! [String: Any]
            DatabaseManager.updateContact(id: contactId, latitude: currentLocationDictionary["latitude"] as! Double, longitude: currentLocationDictionary["longitude"] as! Double, isShare: isShared.rawValue, onCompletion: {
                onCompletionHandler()
            })
        })
    }
}
