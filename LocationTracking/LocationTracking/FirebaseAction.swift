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
    
    //MARK: USER INFORMATION
    //Create new user to sign up firebase
    func createUser(email: String) -> String{
        var resultRef: FIRDatabaseReference = FIRDatabase.database().reference()

        let userInfoDictionary = ["currentLocations": ["latitude":0.0,"longitude":0.0],"email":email] as [String : Any]
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
    
    func resetPasswordToEmail(email: String, onCompletionHandler: @escaping () -> ()) {
        FIRAuth.auth()?.sendPasswordReset(withEmail: email, completion: {_ in
            onCompletionHandler()
        })
    }
    
    //Sign in with Email
    func signInWith(email: String, password: String, completionHandler: @escaping (Bool) -> ()) {
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
                
                self.refreshData(email: email,completionHandler: {isSuccess in
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
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: fromViewControlller) { (result, error) in
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
                    self.refreshData(email: email,completionHandler: {isSuccess in
                        if isSuccess {
                            completionHandler(true)
                        } else {
                            //Create new user on firebase
                            let id = app_delegate.firebaseObject.createUser(email:email)
                            //Create profile in database
                            DatabaseManager.updateProfile(id:id, email:email, latitude: 0, longitude: 0,onCompletionHandler: {_ in
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
                self.refreshData(email: email,completionHandler: {isSuccess in
                    if isSuccess {
                        completionHandler(true)
                    } else {
                        //Create new user on firebase
                        let id = app_delegate.firebaseObject.createUser(email:email)
                        //Create profile in database
                        DatabaseManager.updateProfile(id:id, email:email, latitude: 0, longitude: 0,onCompletionHandler: {_ in
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
                    self.refreshData(email: email,completionHandler: {isSuccess in
                        if isSuccess {
                            completionHandler(true)
                        } else {
                            //Create new user on firebase
                            let id = app_delegate.firebaseObject.createUser(email:email)
                            //Create profile in database
                            DatabaseManager.updateProfile(id:id, email:email, latitude: 0, longitude: 0,onCompletionHandler: {_ in
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
    func searchContactWithEmail(email: String, completionHandler: @escaping ([ContactModel]) -> ()) {
        ref.queryOrdered(byChild: "email").queryStarting(atValue: email).queryEnding(atValue: email+"\u{f8ff}").observe(.value, with: { snapshot in
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
    
    func deleteContact(contactId: String, atUserId: String, onCompletionHandler: @escaping () -> ()) {
        ref.child(atUserId).child("contact").child(contactId).removeValue()
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
    
    func removeObServerContact() {
        ref.removeAllObservers()
    }
    
    //MARK: - Refresh Data
    func refreshData(email: String,completionHandler: @escaping (Bool) -> ()) {
        self.searchContactWithEmail(email: email, completionHandler: { array in
            if array.count > 0 {
                let newProfile: ContactModel = array.first!
                
                //Save profile after login
                DatabaseManager.updateProfile(id: newProfile.id, email: newProfile.email, latitude: newProfile.latitude, longitude: newProfile.longitude,onCompletionHandler: {_ in
                    if newProfile.contact.keys.count == 0 {
                        completionHandler(true)
                        return
                    }
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
