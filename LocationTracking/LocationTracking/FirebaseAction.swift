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
    
    func updateLocation(id: String, lat: Double, long: Double) {
        ref.child(id).child("currentLocations").setValue(["latitude":lat,"longitude":long])
    }
    
    //MARK: - Create new group
    func createGroup(name: String, array: [String]) -> String {
        let profile = DatabaseManager.getProfile()
        if profile?.id != nil {
            //comform to contact id
            var resultRef: FIRDatabaseReference = FIRDatabase.database().reference()
            resultRef = ref.child((profile?.id)!)
            //comform to waiting share property
            let userInfoDictionary = ["name": name, "member":array, "owner": profile?.id!] as [String : Any]
            resultRef.child("group").childByAutoId().setValue(userInfoDictionary)
            return resultRef.child("group").key
        }
        return ""
    }
    
    func updateGroup(snapArray: [String: Any], onCompletionHandler: @escaping ()-> ()) {
        //Get groups list
        for dict in snapArray {
            let value = dict.value as! [String: Any]
            var member = ""
            var name = ""
            var owner = ""
            if value["member"] != nil {
                let memberArray = value["member"] as! [String]
                member = memberArray.joined(separator:",")
            }
            if value["name"] != nil {
                name = value["name"] as! String
            }
            if value["owner"] != nil {
                owner = value["owner"] as! String
            }
            DatabaseManager.updateGroup(id: dict.key, name: name, member: member, owner: owner, onCompletion: {_ in
                if dict.key == Array(snapArray.keys).last {
                    onCompletionHandler()
                }
            })
        }
    }
    
    func deleteGroup(groupId: String, onCompletionHandler: @escaping () -> ()) {
        let profile = DatabaseManager.getProfile()
        ref.child((profile?.id!)!).child("group").child(groupId).removeValue()
        
        DatabaseManager.deleteGroup(grouptId: groupId, onCompletion: {_ in
            onCompletionHandler()
        })
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
        let userName = UserDefaults.standard.object(forKey: "userName") as? String
        if userName != email {
            DatabaseManager.resetAllData(onCompletion: {_ in
                UserDefaults.standard.set(email, forKey: "userName")
                UserDefaults.standard.set(password, forKey: "password")
                UserDefaults.standard.synchronize()
                let id = self.createUser(email: email,name: name)
                onCompletionHandler(id)
            })
        } else {
            let id = self.createUser(email: email,name: name)
            onCompletionHandler(id)
        }
    }
    
    //MARK: - Create new location
    func createNewLocation(latitude: Double, longitude: Double, name: String) -> String {
        let profile = DatabaseManager.getProfile()
        if profile?.id != nil {
            //comform to contact id
            var resultRef: FIRDatabaseReference = FIRDatabase.database().reference()
            resultRef = ref.child((profile?.id)!)
            //comform to waiting share property
            let userInfoDictionary = ["name": name, "latitude":latitude, "longitude": longitude] as [String : Any]
            resultRef.child("locationList").childByAutoId().setValue(userInfoDictionary)
            ref.child("locationList").childByAutoId().setValue(userInfoDictionary)
            return resultRef.child("locationList").key
        }
        return ""
    }
    
    func getProfile(onCompletionHandler: @escaping () -> ()) {
        let profile = DatabaseManager.getProfile()        
        ref.child((profile?.id)!).observe(.value, with: { (snapshot) in
            let snapDict = snapshot.value as? [String : AnyObject] ?? [:]
            self.saveToDatabase(snapDict: snapDict, onCompletionHandler: {_ in
                
            })
        })
    }
    
    func resetPasswordToEmail(email: String, onCompletionHandler: @escaping () -> ()) {
        FIRAuth.auth()?.sendPasswordReset(withEmail: email, completion: {_ in
            onCompletionHandler()
        })
    }
    
    //Sign in with Email
    func signInWith(email: String, name: String?, password: String, completionHandler: @escaping (Bool) -> ()) {
        FIRAuth.auth()?.signIn(withEmail:email, password: password) { (user, error) in
            if error == nil {
                let userName = UserDefaults.standard.object(forKey: "userName") as? String
                if userName != email {
                    DatabaseManager.resetAllData(onCompletion: {_ in
                        UserDefaults.standard.set(email, forKey: "userName")
                        UserDefaults.standard.set(password, forKey: "password")
                        UserDefaults.standard.synchronize()
                    })
                }
                
                self.refreshData(email: email, name: name, completionHandler: {isSuccess in
                    if isSuccess {
                        completionHandler(true)
                    } else {
                        completionHandler(false)
                    }
                })
            } else {
                completionHandler(false)
            }
        }
    }

    //MARK: - Sign in with Facebook
    func signInByFacebook(fromViewControlller: OriginalViewController,completionHandler: @escaping (Bool) -> ()) {
        let fbLoginManager = FBSDKLoginManager()

        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email", "name"], from: fromViewControlller) { (result, error) in
            if let error = error {
                fromViewControlller.view.makeToast("Failed to login: \(error.localizedDescription)")
                completionHandler(false)
                return
            }
            
            guard let accessToken = FBSDKAccessToken.current() else {
                fromViewControlller.view.makeToast("Failed to get access token")
                completionHandler(false)
                return
            }
            
            fromViewControlller.showHUD()
            let credential = FIRFacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            // Perform login by calling Firebase APIs
            FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
                if error != nil {
                    fromViewControlller.view.makeToast((error?.localizedDescription)!, duration: 2.0, position: .center)
                    completionHandler(false)
                } else {
                    var email = ""
                    if user?.email != nil {
                        email = (user?.email)!
                    } else {
                        email = (user?.refreshToken)! + "@gmail.com"
                    }
                    
                    var name = ""
                    if user?.displayName != nil {
                        name = (user?.displayName)!
                    } else {
                        name = "contact"
                    }
                    
                    /**
                     Check user information
                     Reset data if signed other account (remove information in UserDefault)
                     Keep data when signed old account
                     **/
                    let userName = UserDefaults.standard.object(forKey: "userName") as? String
                    if userName != email {
                        DatabaseManager.resetAllData(onCompletion: {_ in
                            UserDefaults.standard.set(email, forKey: "userName")
                            UserDefaults.standard.removeObject(forKey: "password")
                            UserDefaults.standard.synchronize()
                        })
                    }
                    
                    //Update profile information
                    self.refreshData(email: email, name: name, completionHandler: {isSuccess in
                        if isSuccess {
                            completionHandler(true)
                        } else {
                            //Create new user on firebase
                            let id = app_delegate.firebaseObject.createUser(email:email,name: name)
                            //Create profile in database
                            DatabaseManager.updateProfile(id:id, email:email,name:name, latitude: 0, longitude: 0,onCompletionHandler: {_ in
                                //Present after updated profile
                                app_delegate.profile = DatabaseManager.getProfile()
                                completionHandler(true)
                            })
                        }
                    })
                }
            })
        }
    }
    
    //MARK: - Sign in with Google
    func signInByGoogle(authentication: GIDAuthentication,fromViewControlller: OriginalViewController, completionHandler: @escaping (Bool) -> ()) {
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                          accessToken: authentication.accessToken)
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if user != nil {
                self.signOut()
            }
        }
        FIRAuth.auth()?.signIn(with: credential, completion: {(user, error) in
            if error != nil {
                fromViewControlller.view.makeToast((error?.localizedDescription)!, duration: 2.0, position: .center)
                completionHandler(false)
            } else {
                var email = ""
                if user?.email != nil {
                    email = (user?.email)!
                } else {
                    email = (user?.refreshToken)! + "@gmail.com"
                }
                
                var name = ""
                if user?.displayName != nil {
                    name = (user?.displayName)!
                } else {
                    name = "contact"
                }
                
                /**
                 Check user information
                 Reset data if signed other account (remove information in UserDefault)
                 Keep data when signed old account
                 **/
                let userName = UserDefaults.standard.object(forKey: "userName") as? String
                if userName != email {
                    DatabaseManager.resetAllData(onCompletion: {_ in
                        UserDefaults.standard.set(email, forKey: "userName")
                        UserDefaults.standard.removeObject(forKey: "password")
                        UserDefaults.standard.synchronize()
                    })
                }
                
                //Update profile information
                self.refreshData(email: email, name: name, completionHandler: {isSuccess in
                    if isSuccess {
                        completionHandler(true)
                    } else {
                        //Create new user on firebase
                        let id = app_delegate.firebaseObject.createUser(email:email,name: name)
                        //Create profile in database
                        DatabaseManager.updateProfile(id:id, email:email, name:name, latitude: 0, longitude: 0,onCompletionHandler: {_ in
                            //Present after updated profile
                            app_delegate.profile = DatabaseManager.getProfile()
                            completionHandler(true)
                        })
                    }
                })
            }
        })
    }
    
    //MARK: - Sign in with Google
    func signInByTwitter(fromViewControlller: OriginalViewController, completionHandler: @escaping (Bool) -> ()) {
        if (Twitter.sharedInstance().sessionStore.session() != nil) {
            fromViewControlller.showHUD()
        }
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if user != nil {
                self.signOut()
            }
        }
        Twitter.sharedInstance().logIn(completion: { (session, error) in
            fromViewControlller.showHUD()
            if let error = error {
                fromViewControlller.view.makeToast("Failed to login: \(error.localizedDescription)")
                completionHandler(false)
                return
            }
            
            guard let authToken = session?.authToken else {
                fromViewControlller.view.makeToast("Failed to get auth Token")
                completionHandler(false)
                return
            }
            
            fromViewControlller.showHUD()
            let credential = FIRTwitterAuthProvider.credential(withToken: authToken, secret: (session?.authTokenSecret)!)
            // Perform login by calling Firebase APIs
            FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
                if error != nil {
                    completionHandler(false)
                } else {
                    var email = ""
                    if user?.email != nil {
                        email = (user?.email)!
                    } else {
                        email = (user?.displayName)! + "@gmail.com"
                    }
                    
                    var name = ""
                    if user?.displayName != nil {
                        name = (user?.displayName)!
                    } else {
                        name = "contact"
                    }
                    
                    /**
                     Check user information
                     Reset data if signed other account (remove information in UserDefault)
                     Keep data when signed old account
                     **/
                    let userName = UserDefaults.standard.object(forKey: "userName") as? String
                    if userName != email {
                        DatabaseManager.resetAllData(onCompletion: {_ in
                            UserDefaults.standard.set(email, forKey: "userName")
                            UserDefaults.standard.removeObject(forKey: "password")
                            UserDefaults.standard.synchronize()
                        })
                    }
                    
                    //Update profile information
                    self.refreshData(email: email, name: name, completionHandler: {isSuccess in
                        if isSuccess {
                            completionHandler(true)
                        } else {
                            //Create new user on firebase
                            let id = app_delegate.firebaseObject.createUser(email:email,name: name)
                            //Create profile in database
                            DatabaseManager.updateProfile(id:id, email:email, name:name, latitude: 0, longitude: 0,onCompletionHandler: {_ in
                                //Present after updated profile
                                app_delegate.profile = DatabaseManager.getProfile()
                                completionHandler(true)
                            })
                        }
                    })
                }
            })
        })
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
    
    //Reset password 
    func resetPassword(email: String, onComplehandler: @escaping () -> ()) {
        FIRAuth.auth()?.sendPasswordReset(withEmail: email) { error in
            onComplehandler()
        }
    }
    
    //MARK: - Contact
    //Search contact to contact List
    func searchContactWithEmail(email: String?, name: String?, completionHandler: @escaping ([ContactModel]) -> ()) {
        var searchString = ""
        var childName = "email"
        
        if email == nil && name != nil {
            searchString = name!
            childName = "name"
        } else if email != nil && name == nil {
            searchString = email!
            childName = "email"
        }
        
        ref.queryOrdered(byChild: childName).queryStarting(atValue: searchString).queryEnding(atValue: searchString + "\u{f8ff}").observe(.value, with: { snapshot in
            var array = [ContactModel]()
            let snapDic = snapshot.value as? [String:Any]
            guard snapDic != nil else {
                completionHandler(array)
                return
            }
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
    
    func getInformationForKey(contactId:String,isShare: Int?,onCompletionHandler: @escaping () -> ()) {
        ref.child(contactId).observe(.value, with: { (snapshot) in
            var snapDict = snapshot.value as? [String : AnyObject] ?? [:]
            snapDict["isShare"] = isShare as AnyObject?
            snapDict["id"] = contactId as AnyObject?
            self.saveToDatabase(snapDict: snapDict, onCompletionHandler: {_ in
                onCompletionHandler()
            })
        })
    }
    
    func deleteContact(contactId: String, atUserId: String, onCompletionHandler: @escaping () -> ()) {
        ref.child(atUserId).child("contact").child(contactId).removeValue()
        ref.child(contactId).child("contact").child(atUserId).removeValue()

        DatabaseManager.deleteContact(contactId: contactId, onCompletion: {_ in
            onCompletionHandler()
        })
    }
    
    func requestLocation(toContact:Contact, onCompletetionHandler: @escaping () -> ()) {
        var resultRef: FIRDatabaseReference = FIRDatabase.database().reference()
        let profile = DatabaseManager.getProfile()
        
        //comform to contact id
        resultRef = ref.child((toContact.id)!)
        //comform to waiting share property
        resultRef.child("contact").child((profile?.id)!).setValue(ShareStatus.kRequestShare.rawValue)
        
        ref.child((profile?.id)!).child("contact").child(toContact.id!).setValue(ShareStatus.kwaitingShared.rawValue)
        onCompletetionHandler()
    }
    
    func shareLocation(toContact:Contact, onCompletetionHandler: @escaping () -> ()) {
        var resultRef: FIRDatabaseReference = FIRDatabase.database().reference()
        let profile = DatabaseManager.getProfile()
        
        //comform to contact id
        resultRef = ref.child((toContact.id)!)
        //comform to waiting share property
        resultRef.child("contact").child((profile?.id)!).setValue(ShareStatus.kShared.rawValue)
        ref.child((profile?.id)!).child("contact").child(toContact.id!).setValue(ShareStatus.kShared.rawValue)
        
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
    
    func changePassword(oldPassword: String, newPassword: String, onCompletionHandler: @escaping (Error?) -> ()) {
        let user = FIRAuth.auth()?.currentUser
        let profile = DatabaseManager.getProfile()! as Profile
        
        let credential = FIREmailPasswordAuthProvider.credential(withEmail: profile.email!, password: oldPassword)
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
                        onCompletionHandler(nil)
                    }
                }
            }
        }
    }
    
    func removeObServerContact() {
        ref.removeAllObservers()
    }
    
    //MARK: - Refresh Data
    func refreshData(email: String, name: String?, completionHandler: @escaping (Bool) -> ()) {
        self.searchContactWithEmail(email: email,name: nil, completionHandler: { array in
            if array.count > 0 {
                let newProfile: ContactModel = array.first!
                
                //Save profile after login
                DatabaseManager.updateProfile(id: newProfile.id, email: newProfile.email, name: newProfile.name, latitude: newProfile.latitude, longitude: newProfile.longitude,onCompletionHandler: {_ in
                    
                    self.getLocationList(fromId: newProfile.id) {
                        
                    }
                    //New Account which hasn't yet any contact in contacts list
                    if newProfile.contact.keys.count == 0 && newProfile.group.keys.count == 0 {
                        completionHandler(true)
                        return
                    }
                    
                    //update contact information in contacts list
                    for dict in newProfile.contact {
                        self.getInformationForKey(contactId: dict.key, isShare:dict.value as? Int,onCompletionHandler: {_ in
                            
                            if dict.key == Array(newProfile.contact.keys).last! {
                                //Update group list
                                if newProfile.group.count != 0 {
                                    self.updateGroup(snapArray: newProfile.group, onCompletionHandler: {
                                        completionHandler(true)
                                    })
                                } else {
                                    completionHandler(true)
                                }
                            }
                            
                        })
                    }
                })
            } else {
                completionHandler(false)
            }
        })
    }
    
    //MARK: - Location list
    func getLocationList(fromId: String, onCompletionHandler: @escaping () -> ()) {
        ref.child(fromId).child("locationList").observe(.value, with: { (snapshot) in
            let snapDict = snapshot.value as? [String: AnyObject] ?? [:]
            
            for dict in snapDict {
                let location = dict.value as? [String: Any]
                let name = location!["name"] as! String
                let latitude = location!["latitude"] as! Double
                let longitude = location!["longitude"] as! Double
                
                DatabaseManager.updateLocationList(id: dict.key, name: name , latitude: latitude, longitude: longitude, onCompletionHandler: {
                    if dict.key == Array(snapDict.keys).last {
                        print(snapDict.description)
                        onCompletionHandler()
                    }
                })
            }
        })
    }
    
    func deleteLocation(locationId: String, onCompletionHandler: @escaping () -> ()) {
        let profile = DatabaseManager.getProfile()
        ref.child((profile?.id!)!).child("locationList").child(locationId).removeValue()
        
        DatabaseManager.deleteLocation(locationId: locationId, onCompletion: {_ in
            onCompletionHandler()
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
            let name = snapDict["name"] as! String
            let profile = DatabaseManager.getProfile()
            if profile?.email == email {
                //Update profile
                DatabaseManager.updateProfile(id: (profile?.id)!, email: email, name: name, latitude: currentLocationDictionary["latitude"] as! Double, longitude: currentLocationDictionary["longitude"] as! Double, onCompletionHandler: {_ in
                    self.getLocationList(fromId: (profile?.id)!, onCompletionHandler: {_ in
                    })
                    
                    if snapDict["contact"] != nil {
                        let contactDictionary = snapDict["contact"] as! [String:Any]
                        for dict in contactDictionary {
                            let isShare = (dict.value as! NSNumber).intValue
                            DatabaseManager.updateContact(id: dict.key, name: nil, latitude: nil, longitude: nil, isShare: isShare, onCompletion: {
                                if dict.key == Array(contactDictionary.keys).last {
                                    //Update group list
                                    if snapDict["group"] != nil {
                                        let groupArray = snapDict["group"] as! [String: Any]
                                        self.updateGroup(snapArray: groupArray, onCompletionHandler: {
                                            onCompletionHandler()
                                        })
                                    } else {
                                        onCompletionHandler()
                                    }
                                }
                            })
                        }
                    }
                })
            } else {
                //Update contact
                var isShare:Int? = nil
                if snapDict["isShare"] != nil {
                    isShare = snapDict["isShare"] as? Int
                }
                
                let name = snapDict["name"] == nil ? "" : snapDict["name"] as! String
                
                DatabaseManager.updateContactWithEmail(id:id,email: email, name: name, latitude: currentLocationDictionary["latitude"] as! Double, longitude: currentLocationDictionary["longitude"] as! Double, isShare: isShare, onCompletion: {
                    onCompletionHandler()
                })
            }
            
        }
    }
    
    //MARK: - Send Comment about App
    func sendCommentAboutApp(comment: String, onCompletetionHandler: @escaping () -> ()) {
        var resultRef: FIRDatabaseReference = FIRDatabase.database().reference()
        resultRef = ref.child("comment")
        
        let profile = DatabaseManager.getProfile()
        /**
         Key: profile id
         Value: comment
        **/
        let dictionary = [(profile?.id)!: comment]
        
        resultRef.childByAutoId().setValue(dictionary)
        onCompletetionHandler()
    }
    
    func getAbout(onCompletionHandler: @escaping () -> ()) {
        ref.child("about").observe(.value, with: { (snapshot) in
            UserDefaults.standard.set(snapshot.value as? String, forKey: "about")
            onCompletionHandler()
        })
    }
}
