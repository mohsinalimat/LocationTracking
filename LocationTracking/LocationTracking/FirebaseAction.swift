//
//  FirebaseAction.swift
//  LocationTracking
//
//  Created by Nguyen Hai Dang on 6/17/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import GoogleSignIn
import TwitterKit
import TwitterCore
import Social

class FirebaseAction: NSObject {
    
    lazy var ref: FIRDatabaseReference = FIRDatabase.database().reference()
    
    func initFirebase() {
        FIRApp.configure()
        FIRDatabase.database().reference()
    }
    
    //MARK: - Get from firebase
    func getContact(email: String, onCompletionHandler: @escaping ([String:Any]) -> ()) {
        ref.queryOrdered(byChild: "email").queryStarting(atValue: email).queryEnding(atValue: email + "\u{f8ff}").observe(.value, with: { snapshot in
            let snapDic = snapshot.value as? [String:Any]
            guard snapDic != nil else {
                onCompletionHandler([String:Any]())
                return
            }
            onCompletionHandler(snapDic!)
        })
    }
    
    func observeLocation() {
        ref.child(app_delegate.profile.id).child("locationList").observe(.childChanged, with: {snapShot in
            let snapDic = snapShot.value as? [String:Any]
            guard snapDic != nil else {
                return
            }
            
            //clear data
            app_delegate.locationArray.removeAll()

            //fill data
            for child in snapDic! {
                var allDict = child.value as? [String:Any]
                allDict?["id"] = child.key
                
                let locationModel = LocationModel()
                locationModel.initLocationModel(dict: allDict!)
                app_delegate.locationArray.append(locationModel)
            }
            
            NotificationCenter.default.post(name: Notification.Name("ChangedLocation"), object: nil)
        })
    }
    
    func observeGroup() {
        ref.child(app_delegate.profile.id).child("group").observe(.value, with: {snapShot in
            let snapDic = snapShot.value as? [String:Any]
            guard snapDic != nil else {
                return
            }
            
            //clear data
            app_delegate.groupArray.removeAll()
            
            //fill data
            
            for child in snapDic! {
                var allDict = child.value as? [String:Any]
                allDict?["id"] = child.key
                
                let groupModel = GroupModel()
                groupModel.initGroupModel(dict: allDict!)
                app_delegate.groupArray.append(groupModel)
            }
            
            NotificationCenter.default.post(name: Notification.Name("ChangedGroup"), object: nil)
        })
    }
    
    func observeContact() {
        ref.child(app_delegate.profile.id).child("contact").observe(.childChanged, with: {snapShot in
            let snapDic = snapShot.value as? [String:Any]
            guard snapDic != nil else {
                return
            }
            
            //clear data
            app_delegate.contactArray.removeAll()
            
            //fill data
            for child in snapDic! {
                self.ref.child(child.key).observe(.value, with: {snap in
                    var dict = snap.value as! [String: Any]
                    
                    dict["id"] = child.key
                    let contact = ContactModel()
                    contact.initContactModel(dict: dict)
                    contact.isShare = child.value as! Int
                    app_delegate.contactArray.append(contact)
                    
                    if app_delegate.contactArray.count == snapDic?.keys.count {
                        NotificationCenter.default.post(name: Notification.Name("ChangedContact"), object: nil)
                    }
                })
            }
        })
    }
    
    //MARK: - Update to firebase
    func updateLocation(id: String, lat: Double, long: Double) {
        ref.child(id).child("currentLocations").setValue(["latitude":lat,"longitude":long])
    }
    
    func updateName(name: String) {
        ref.child(app_delegate.profile.id).child("name").setValue(name)
    }
    
    func updateEmail(email: String) {
        ref.child(app_delegate.profile.id).child("email").setValue(email)
    }
    
    //MARK: USER INFORMATION
    //Create new user to sign up firebase
    func createUser(email: String, name:String) -> String{
        var resultRef: FIRDatabaseReference = FIRDatabase.database().reference()

        let userInfoDictionary = ["currentLocations": ["latitude":0.0,"longitude":0.0],"email":email,"name":name] as [String : Any]
        resultRef = ref.childByAutoId()
        resultRef.setValue(userInfoDictionary)
        return resultRef.key
    }
    
    func registerNewAccount(email: String,password: String, name: String, onCompletionHandler: @escaping (String) -> ()) {
        UserDefaults.standard.set(email, forKey: "userName")
        UserDefaults.standard.set(password, forKey: "password")
        UserDefaults.standard.synchronize()
        let id = self.createUser(email: email,name: name)
        onCompletionHandler(id)
    }
    
    //MARK: - Create new location
    func createNewLocation(latitude: Double, longitude: Double, name: String) {
            //comform to contact id
            var resultRef: FIRDatabaseReference = FIRDatabase.database().reference()
            resultRef = ref.child(app_delegate.profile.id)
            //comform to waiting share property
            let userInfoDictionary = ["name": name, "latitude":latitude, "longitude": longitude] as [String : Any]
            let id = Common.getCurrentTimeStamp()
            
            resultRef.child("locationList").child(id).setValue(userInfoDictionary)
            ref.child("locationList").child(id).setValue(userInfoDictionary)
    }
    
    //MARK: - Create new location
    func addLocationToContact(id: String, locationAray: [LocationModel]) {
        //comform to contact id
        var resultRef: FIRDatabaseReference = FIRDatabase.database().reference()
        resultRef = ref.child(id)
        //comform to waiting share property
        for location in locationAray {
            let userInfoDictionary = ["name": location.name, "latitude": location.latitude, "longitude": location.longitude] as [String : Any]
            resultRef.child("locationList").child(location.id).setValue(userInfoDictionary)
        }
    }
    
    func resetPasswordToEmail(email: String, onCompletionHandler: @escaping () -> ()) {
        FIRAuth.auth()?.sendPasswordReset(withEmail: email, completion: {_ in
            onCompletionHandler()
        })
    }
    
    //MARK: - Sign in with Email
    func signInWith(email: String, name: String?, password: String, completionHandler: @escaping (Bool) -> ()) {
        FIRAuth.auth()?.signIn(withEmail:email, password: password) { (user, error) in
            if error == nil {
                UserDefaults.standard.set(email, forKey: "userName")
                UserDefaults.standard.set(password, forKey: "password")
                UserDefaults.standard.synchronize()
                
                //Init profile
                self.getContact(email: email, onCompletionHandler: {snapDict in
                    var dict = snapDict.values.first as! [String: Any]
                    dict["id"] = snapDict.keys.first
                    app_delegate.profile.initContactModel(dict: dict)
                    
                    /** Add observe
                     - Location
                     - Group
                     - Contact
                     **/
                    self.observeLocation()
                    
                    self.observeGroup()
                    
                    self.observeContact()
                    
                    completionHandler(true)
                })
                
            } else {
                completionHandler(false)
            }
        }
    }
    
    //Sign out
    func signOut(){
        do{
            try FIRAuth.auth()?.signOut()
        }catch{
            print("Error while signing out!")
        }
    }
    
    //Reset password 
    func resetPassword(email: String, onComplehandler: @escaping () -> ()) {
        FIRAuth.auth()?.sendPasswordReset(withEmail: email) { error in
            onComplehandler()
        }
    }
    
    //MARK: - Contact

    
    //Search contact to contact List
    func searchContactWithName(name: String?, completionHandler: @escaping ([ContactModel]) -> ()) {
        var searchString = ""
        
        if name != nil {
            searchString = name!
        }
        
        ref.queryOrdered(byChild: "name").observe(.value, with: { snapshot in
            var array = [ContactModel]()
            let snapDic = snapshot.value as? [String:Any]
            guard snapDic != nil else {
                completionHandler(array)
                return
            }
            for child in snapDic! {
                var allDict = child.value as? [String:Any]
                allDict?["id"] = child.key
                
                var name = ""
                if allDict?["name"] != nil {
                    name = allDict?["name"] as! String
                }
                if name.contains(searchString) {
                    let contactModel = ContactModel()
                    contactModel.initContactModel(dict: allDict!)
                    array.append(contactModel)
                    print(child)
                }
            }
            completionHandler(array)
        })
    }
    
    func searchLocation(searchString: String, onCompletionHandler: @escaping ([LocationModel]) -> ()) {
        ref.child("locationList").observe(.value, with: { snapshot in
            var array = [LocationModel]()
            let snapDic = snapshot.value as? [String:Any]
            guard snapDic != nil else {
                onCompletionHandler(array)
                return
            }
            for child in snapDic! {
                var allDict = child.value as? [String:Any]
                allDict?["id"] = child.key
                let name = allDict?["name"] as! String
                if name.uppercased().contains(searchString.uppercased()) {
                    let locationModel = LocationModel()
                    locationModel.initLocationModel(dict: allDict!)
                    array.append(locationModel)
                    print(child)
                }
            }
            onCompletionHandler(array)
        })
    }
    
    func deleteContact(contactId: String, atUserId: String, onCompletionHandler: @escaping () -> ()) {
        ref.child(atUserId).child("contact").child(contactId).removeValue()
        ref.child(contactId).child("contact").child(atUserId).removeValue()
        onCompletionHandler()
    }
    
    func shareLocation(toContact: ContactModel, onCompletetionHandler: @escaping () -> ()) {
        var resultRef: FIRDatabaseReference = FIRDatabase.database().reference()
        
        //comform to contact id
        resultRef = ref.child(toContact.id)
        //comform to waiting share property
        resultRef.child("contact").child(app_delegate.profile.id).setValue(ShareStatus.kShared.rawValue)
    ref.child(app_delegate.profile.id).child("contact").child(toContact.id).setValue(ShareStatus.kShared.rawValue)
        
        onCompletetionHandler()
    }
    
    func changePassword(oldPassword: String, newPassword: String, onCompletionHandler: @escaping (Error?) -> ()) {
        let user = FIRAuth.auth()?.currentUser
        
        let credential = FIREmailPasswordAuthProvider.credential(withEmail: app_delegate.profile.email, password: oldPassword)
        user?.reauthenticate(with: credential) { reAuthError in
            if reAuthError != nil {
                onCompletionHandler(reAuthError!)
                // An error happened.
            } else {
                user?.updatePassword(newPassword) { error in
                    if error != nil {
                        onCompletionHandler(error!)
                    } else {
                        // Password updated.
                        UserDefaults.standard.set(newPassword, forKey: "password")
                        UserDefaults.standard.synchronize()
                        
                        onCompletionHandler(nil)
                    }
                }
            }
        }
    }
    
    func changeEmail(newEmail: String, password: String, onCompletionHandler: @escaping (Error?) -> ()) {
        let user = FIRAuth.auth()?.currentUser
        
        let credential = FIREmailPasswordAuthProvider.credential(withEmail: app_delegate.profile.email, password: password)
        user?.reauthenticate(with: credential) { reAuthError in
            if reAuthError != nil {
                onCompletionHandler(reAuthError!)
                // An error happened.
            } else {
                user?.updateEmail(newEmail, completion: { error in
                    if error != nil {
                        onCompletionHandler(error!)
                    } else {
                        // Password updated.
                        UserDefaults.standard.set(newEmail, forKey: "userName")
                        UserDefaults.standard.synchronize()
                        onCompletionHandler(nil)
                    }
                })
            }
        }
    }
}
