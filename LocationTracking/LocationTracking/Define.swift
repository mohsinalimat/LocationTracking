//
//  Define.swift
//  LocationTracking
//
//  Created by Nguyen Hai Dang on 6/17/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import Foundation
import UIKit

let kShared        = 0     //Shared location with me
let kRequested     = 1     //I requested
let kRequestedToMe = 2     //Requested me

//MARK: - Key
//Twitter
let kConsumerKey          = "tyUS13Zcb3luNoCF7MeUiiLyz"
let kConsumerSecret       = "aNiteoUYaYJX5iG7j2yZuZkvjt2IYklv2o77oFJOg2cxYtXvMW"

//Admob
let kBannerAdUnitId       = "ca-app-pub-7161181863245899/7966804686"
let kInterstitialAdUnitID = "ca-app-pub-7161181863245899/7581514074"
let kApplicationId        = "ca-app-pub-7161181863245899~5560133192"

//MARK: - Index
let kSharedContactIndex    = 0     //Shared location with me
let kRequestShareIndex     = 1     //Contacts who request to me
let kGroupListIndex        = 2     //Group list
let kLocationListIndex     = 3     //Location list

let main_storyboard     = UIStoryboard(name: "Main", bundle: nil)
let screen_width        = UIScreen.main.bounds.width
let screen_height       = UIScreen.main.bounds.height
let app_delegate        = UIApplication.shared.delegate as! AppDelegate
let kDrawerWidth: CGFloat        = 50.0
