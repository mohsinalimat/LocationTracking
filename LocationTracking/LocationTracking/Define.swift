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
    case kNotYetShared  = 0
    case kShared        = 1
    case kwaitingShared = 2
    case kRequestShare  = 3
}

let kContactListIndex   = 0
let kRequestShareIndex  = 1

let main_storyboard     = UIStoryboard(name: "Main", bundle: nil)
let screen_width        = UIScreen.main.bounds.width
let screen_height       = UIScreen.main.bounds.height
let app_delegate        = UIApplication.shared.delegate as! AppDelegate
//let color_main      = UIColor.init(red: <#T##CGFloat#>, green: <#T##CGFloat#>, blue: <#T##CGFloat#>, alpha: <#T##CGFloat#>)
