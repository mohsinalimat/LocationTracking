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
    
    func createUser(nickName: String, userName: String, birthday: String) {
        let userInfoDictionary = ["currentLocations": ["latitude":0,"longitude":0],"nickName":nickName,"userName":userName,"birthday":birthday] as [String : Any]
        
        ref.childByAutoId().setValue(userInfoDictionary)
    }
}
