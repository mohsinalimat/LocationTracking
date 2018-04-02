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
let kConsumerKey            = "tyUS13Zcb3luNoCF7MeUiiLyz"
let kConsumerSecret         = "aNiteoUYaYJX5iG7j2yZuZkvjt2IYklv2o77oFJOg2cxYtXvMW"

//Admob
let kBannerAdUnitId         = "ca-app-pub-4981657393585558/9434507014"
let kInterstitialAdUnitID   = "ca-app-pub-4981657393585558/1141918176"
let kApplicationId          = "ca-app-pub-4981657393585558~7459914518"

//MARK: - Index
let kSharedContactIndex     = 0     //Shared location with me
let kRequestShareIndex      = 1     //Contacts who request to me
let kGroupListIndex         = 2     //Group list
let kLocationListIndex      = 3     //Location list

let main_storyboard         = UIStoryboard(name: "Main", bundle: nil)
let screen_width            = UIScreen.main.bounds.width
let screen_height           = UIScreen.main.bounds.height
let app_delegate            = UIApplication.shared.delegate as! AppDelegate
let kUserDefault            = UserDefaults.standard
let kDrawerWidth: CGFloat   = 50.0
let kLanguageCode           = "language_code"
