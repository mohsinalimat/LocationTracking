//
//  FirebaseAction.swift
//  LocationTracking
//
//  Created by Nguyen Hai Dang on 6/17/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit
import Firebase
import Social

class FirebaseAction: NSObject {
    
    lazy var ref: DatabaseReference = Database.database().reference()
    
    func initFirebase() {
        FirebaseApp.configure()
        Database.database().reference()
    }
    
    //MARK: - Get from firebase
    func getContact(email: String, onCompletionHandler: @escaping ([String:Any]) -> ()) {
        ref.queryOrdered(byChild: "email").queryStarting(atValue: email).queryEnding(atValue: email + "\u{f8ff}").observeSingleEvent(of: .value, with: { snapshot in
            let snapDic = snapshot.value as? [String:Any]
            guard snapDic != nil else {
                onCompletionHandler([String:Any]())
                return
            }
            onCompletionHandler(snapDic!)
        })
    }
    
    func observeChangedLocation() {
        //Child changed
        ref.child(app_delegate.profile.id).child("locationList").observe(.value, with: {snapShot in
            print("Key Snapshot: " + snapShot.key + snapShot.description)

            self.reloadLocationDataWhenChanged(snapDic: snapShot.value as? [String:Any])
        })
        ref.child(app_delegate.profile.id).child("locationList").observe(.childRemoved, with: {snapShot in
            //Remove location that removed
            app_delegate.locationArray = app_delegate.locationArray.filter{$0.id != snapShot.key}
            
            //Post notification to update UI
            NotificationCenter.default.post(name: Notification.Name("ChangedLocation"), object: nil)
        })
    }
    
    func reloadLocationDataWhenChanged(snapDic: [String:Any]?) {
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
    }
    
    func observeGroup() {
        ref.child(app_delegate.profile.id).child("group").observe(.value, with: {snapShot in
            let groupArray = snapShot.value as? [String]
            guard groupArray != nil else {
                app_delegate.groupArray.removeAll()
                NotificationCenter.default.post(name: Notification.Name("ChangedGroup"), object: nil)
                return
            }
            
            //clear data
            app_delegate.groupArray.removeAll()
            
            //fill data
            for groupName in groupArray! {
                self.ref.child("group").child(groupName).observeSingleEvent(of: .value, with: {snap in
                    var dict = snap.value as! [String: Any]
                    dict["id"] = groupName
                    let groupModel = GroupModel()
                    groupModel.initGroupModel(dict: dict)
                    
                    app_delegate.groupArray = app_delegate.groupArray.filter{$0.id != groupName}
                    app_delegate.groupArray.insert(groupModel, at: 0)
                    
                    if app_delegate.groupArray.count == groupArray?.count {
                        NotificationCenter.default.post(name: Notification.Name("ChangedGroup"), object: nil)
                    }
                })
            }
        })
        
        ref.child(app_delegate.profile.id).child("group").observe(.childRemoved, with: {snapShot in
            //Remove location that removed
            app_delegate.groupArray = app_delegate.groupArray.filter{$0.id != snapShot.value as? String}
            
            //Post notification to update UI
            NotificationCenter.default.post(name: Notification.Name("ChangedGroup"), object: nil)
        })
    }
    
    func observeContact() {
        ref.child(app_delegate.profile.id).child("contact").observe(.value, with: {snapShot in
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
                    
                    if contact.contact[app_delegate.profile.id] != nil {
                        app_delegate.contactArray = app_delegate.contactArray.filter{$0.id != contact.id}
                        app_delegate.contactArray.append(contact)
                    }
                    
                    if app_delegate.contactArray.count == snapDic?.keys.count {
                        NotificationCenter.default.post(name: Notification.Name("ChangedContact"), object: nil)
                    }
                })
            }
        })
        
        ref.child(app_delegate.profile.id).child("contact").observe(.childRemoved, with: {snapShot in
            //Remove location that removed
            app_delegate.contactArray = app_delegate.contactArray.filter{$0.id != snapShot.key}
            
            //Post notification to update UI
            NotificationCenter.default.post(name: Notification.Name("ChangedContact"), object: nil)
        })
    }
    
    func observeProfile() {
        ref.child(app_delegate.profile.id).observe(.value, with: { snapshot in
            guard let dict = snapshot.value as? [String: Any] else {return}
            app_delegate.profile.initContactModel(dict: dict)
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
        var resultRef: DatabaseReference = Database.database().reference()

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
        var resultRef: DatabaseReference = Database.database().reference()
            resultRef = ref.child(app_delegate.profile.id)
            //comform to waiting share property
            let userInfoDictionary = ["name": name, "latitude":latitude, "longitude": longitude] as [String : Any]
            let id = Common.getCurrentTimeStamp()
            
            resultRef.child("locationList").child(id).setValue(userInfoDictionary)
            ref.child("locationList").child(id).setValue(userInfoDictionary)
    }
    
    func addLocationToContact(id: String, locationAray: [LocationModel]) {
        //comform to contact id
        var resultRef: DatabaseReference = Database.database().reference()
        resultRef = ref.child(id)
        //comform to waiting share property
        for location in locationAray {
            let userInfoDictionary = ["name": location.name, "latitude": location.latitude, "longitude": location.longitude] as [String : Any]
            resultRef.child("locationList").child(location.id).setValue(userInfoDictionary)
        }
    }
    
    func deleteLocation(locationId: String){
        ref.child(app_delegate.profile.id).child("locationList").child(locationId).removeValue()
    }
    
    //MARK: - Create new Group
    func createGroup(name: String, array: [String], onCompletionHandler: @escaping ()-> ()) {
        //comform to contact id
        //comform to waiting share property
        let userInfoDictionary = ["name": name, "member":array, "owner": app_delegate.profile.id] as [String : Any]
        
        //create group
        let group = ref.child("group").childByAutoId()
        group.setValue(userInfoDictionary)
        
        var newGroupIdArray = [String]()
        
        //Get current group list
        for groupModel in app_delegate.groupArray {
            newGroupIdArray.append(groupModel.id)
        }
        
        //Add new group is
        newGroupIdArray.append(group.key)

        //Add new group to my group list
        self.ref.child(app_delegate.profile.id).child("group").setValue(newGroupIdArray)

        var count = 0
        //referent to user
        for user in array {
            if user != app_delegate.profile.id {
                ref.child(user).child("group").observe(.value, with: { (snapshot) in
                    count += 1
                    var snapDict = snapshot.value as? [String] ?? []
                    if !snapDict.contains(group.key) {
                        snapDict.append(group.key)
                    }
                    self.ref.child(user).child("group").setValue(snapDict)
                    if count == array.count {
                        onCompletionHandler()
                    }
                })
            }
        }
    }
    
    func addContactToGroup(groupId: String, contactArray: [ContactModel], onCompletionHandler: @escaping () -> ()) {
        self.ref.child("group").child(groupId).child("member").observeSingleEvent(of: .value, with: {(snapshot) in
            //Add contacts to group
            var snapDict = snapshot.value as? [String] ?? []
            for contact in contactArray {
                snapDict.append(contact.id)
            }
            self.ref.child("group").child(groupId).child("member").setValue(snapDict)
            
            //Add group to each contact
            var count = 0
            for contact in contactArray {
                self.ref.child(contact.id).child("group").observeSingleEvent(of: .value, with: { (snapshot) in
                    count += 1
                    var snapDict = snapshot.value as? [String] ?? []
                    if !snapDict.contains(groupId) {
                        snapDict.append(groupId)
                    }
                    self.ref.child(contact.id).child("group").setValue(snapDict)
                    if count == contactArray.count {
                        onCompletionHandler()
                    }
                })
            }
        })
    }
    
    func deleteGroup(group: GroupModel) {
        let newGroupArray = app_delegate.groupArray.filter{$0.id != group.id}
        var groupIdArray = [String]()
        let memberIdArray = group.member.filter{$0 != app_delegate.profile.id}
        
        for newGroup in newGroupArray {
            groupIdArray.append(newGroup.id)
        }

        //Update Group list
        ref.child(app_delegate.profile.id).child("group").setValue(groupIdArray)
        
        ref.child("group").child(group.id).child("member").setValue(memberIdArray)
    }
    
    //MARK: - User
    func resetPasswordToEmail(email: String, onCompletionHandler: @escaping () -> ()) {
        Auth.auth().sendPasswordReset(withEmail: email, completion: {_ in
            onCompletionHandler()
        })
    }
    
    func signInWith(email: String, name: String?, password: String, completionHandler: @escaping (Bool) -> ()) {
        Auth.auth().signIn(withEmail:email, password: password) { (user, error) in
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
                    self.observeChangedLocation()
                    
                    self.observeGroup()
                    
                    self.observeContact()
                    
                    self.observeProfile()
                    
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
            try Auth.auth().signOut()
        }catch{
            print("Error while signing out!")
        }
    }
    
    //Reset password 
    func resetPassword(email: String, onComplehandler: @escaping () -> ()) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            onComplehandler()
        }
    }
    
    //MARK: - Contact

    func searchContactWithId(idArray: [String], completionHandler: @escaping ([ContactModel]) -> ()) {
        var array = [ContactModel]()

        for id in idArray {
            ref.child(id).observeSingleEvent(of: .value, with: { snapshot in
                var snapDic = snapshot.value as? [String:Any]
                guard snapDic != nil else {
                    completionHandler(array)
                    return
                }
                snapDic?["id"] = snapshot.key
                
                let contactModel = ContactModel()
                contactModel.initContactModel(dict: snapDic!)
                array.append(contactModel)
                completionHandler(array)
            })

        }
    }
    
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
                if name.uppercased().contains(searchString.uppercased()) {
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
        //Remove me by this contact
        ref.child(toContact.id).child("contact").child(app_delegate.profile.id).setValue(kShared)
        
        //Remove this contact by me
        ref.child(app_delegate.profile.id).child("contact").child(toContact.id).setValue(kShared)
        
        onCompletetionHandler()
    }
    
    func requestToShareLocation(selectContactArray: [ContactModel]) {
        var contactList = app_delegate.profile.contact
        
        for selectContact in selectContactArray {
            contactList[selectContact.id] = kRequested
            
            //Add me to selected contact
            var selectContactList = selectContact.contact
            selectContactList[app_delegate.profile.id] = kRequestedToMe
            
            ref.child(selectContact.id).child("contact").setValue(selectContactList)
        }
        
        //Add new contact to my contact array
        ref.child(app_delegate.profile.id).child("contact").setValue(contactList)
    }
    
    //MARK: - Change user information
    func changePassword(oldPassword: String, newPassword: String, onCompletionHandler: @escaping (Error?) -> ()) {
        let user = Auth.auth().currentUser
        
        let credential = EmailAuthProvider.credential(withEmail: app_delegate.profile.email, password: oldPassword)
        
        user?.reauthenticate(with: credential) { reAuthError in
            if reAuthError != nil {
                onCompletionHandler(reAuthError!)
                // An error happened.
            } else {
                user?.updatePassword(to: newPassword, completion:{ error in
                    if error != nil {
                        onCompletionHandler(error!)
                    } else {
                        // Password updated.
                        UserDefaults.standard.set(newPassword, forKey: "password")
                        UserDefaults.standard.synchronize()
                        
                        onCompletionHandler(nil)
                    }
                })
            }
        }
    }
    
    func changeEmail(newEmail: String, onCompletionHandler: @escaping (Error?) -> ()) {
        let user = Auth.auth().currentUser
        
        let password = UserDefaults.standard.object(forKey: "password") ?? ""

        let credential = EmailAuthProvider.credential(withEmail: app_delegate.profile.email, password: password as! String)
        user?.reauthenticate(with: credential) { reAuthError in
            if reAuthError != nil {
                onCompletionHandler(reAuthError!)
                // An error happened.
            } else {
                user?.updateEmail(to: newEmail, completion: { error in
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
    
    //MARK: - About
    func getAbout(onCompletionHandler: @escaping () -> ()) {
        ref.child("about").observe(.value, with: { (snapshot) in
            UserDefaults.standard.set(snapshot.value as? String, forKey: "about")
            onCompletionHandler()
        })
    }
    
    func sendCommentAboutApp(comment: String, onCompletetionHandler: @escaping () -> ()) {
        var resultRef: DatabaseReference = Database.database().reference()
        resultRef = ref.child("comment")
        
        /**
         Key: profile id
         Value: comment
         **/
        let dictionary = [app_delegate.profile.id: comment]
        
        resultRef.childByAutoId().setValue(dictionary)
        onCompletetionHandler()
    }
}
