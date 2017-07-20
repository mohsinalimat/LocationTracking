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
        FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
            if error == nil {
                completionHandler(true)
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
    
    func requestLocation(toContact:Contact, onCompletetionHandler: @escaping () -> ()) {
        var resultRef: FIRDatabaseReference = FIRDatabase.database().reference()
        let profile = DatabaseManager.getProfile()
        
        let newWaitingShare = toContact.waitingShare! + (profile?.id)!
        let userInfoDictionary = ["waitingShare": newWaitingShare] as [String : Any]
        resultRef = ref.child((toContact.id)!)
        resultRef.setValue(userInfoDictionary)
        onCompletetionHandler()
    }
}
