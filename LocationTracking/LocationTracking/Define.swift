//
//  Define.swift
//  LocationTracking
//
//  Created by Nguyen Hai Dang on 6/17/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import Foundation
import UIKit

enum ShareStatus: Int {
    case kShared        = 0
    case kwaitingShared = 1
    case kRequestShare  = 2
    case kNotYetShared  = 3
}

//MARK: - Key
let kConsumerKey        = "tyUS13Zcb3luNoCF7MeUiiLyz"
let kConsumerSecret     = "aNiteoUYaYJX5iG7j2yZuZkvjt2IYklv2o77oFJOg2cxYtXvMW"

//MARK: - Index
let kContactListIndex   = 0
let kRequestShareIndex  = 1

let main_storyboard     = UIStoryboard(name: "Main", bundle: nil)
let screen_width        = UIScreen.main.bounds.width
let screen_height       = UIScreen.main.bounds.height
let app_delegate        = UIApplication.shared.delegate as! AppDelegate
//let color_main      = UIColor.init(red: <#T##CGFloat#>, green: <#T##CGFloat#>, blue: <#T##CGFloat#>, alpha: <#T##CGFloat#>)
