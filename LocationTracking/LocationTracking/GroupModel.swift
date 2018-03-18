//
//  GroupModel.swift
//  LocationTracking
//
//  Created by Thuy Phan on 3/11/18.
//  Copyright © 2018 Nguyen Hai Dang. All rights reserved.
//

import UIKit

class GroupModel: NSObject {
    var member = [String]()
    var owner: String = ""
    var id: String = ""
    var name: String = ""
    
    func initGroupModel(dict: [String:Any]) {
        if dict["name"] != nil {
            self.name = dict["name"] as! String
        }
        if dict["id"] != nil {
            self.id = dict["id"] as! String
        }
        
        if dict["owner"] != nil {
            self.owner = dict["owner"] as! String
        }
        if dict["member"] != nil {
            self.member = dict["member"] as! [String]
        }
    }
}
