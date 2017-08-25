//
//  AppDelegate.swift
//  LocationTracking
//
//  Created by Nguyen Hai Dang on 6/1/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit
import CoreData
import GoogleMaps
import GooglePlaces
import MagicalRecord
import Firebase
import FBSDKCoreKit
import GoogleSignIn
import TwitterKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var firebaseObject = FirebaseAction()
    var profile: Profile?
    var refHandler = FIRDatabaseReference()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //Set up Google API Key
        GMSServices.provideAPIKey("AIzaSyB-vkbuoB24Hb8StdNS_mw4VaAN7oiZMe0")
        GMSPlacesClient.provideAPIKey("AIzaSyB-vkbuoB24Hb8StdNS_mw4VaAN7oiZMe0")

        //Init Magical Record
        MagicalRecord.setupCoreDataStack()
        
        //Init Firebase
        firebaseObject.initFirebase()
        
        //Init FBSDK
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        //Init GoogleSDK
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        
        //Init Twiter
        Twitter.sharedInstance().start(withConsumerKey: kConsumerKey, consumerSecret: kConsumerSecret)
        
        GADMobileAds.configure(withApplicationID: kApplicationId)

        profile = DatabaseManager.getProfile()
        
        //Save new profile information
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let facebookHandled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        var googleHandled = false
        if #available(iOS 9.0, *) {
            googleHandled = GIDSignIn.sharedInstance().handle(url,sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
        }
        
        if facebookHandled {
            return facebookHandled
        } else if googleHandled {
            return googleHandled
        } else {
            return true
        }
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
    
    //MARK: - set rootViewController
    func initRevealViewController() -> KYDrawerController{
        //Init root view controller
        //Main Controller
        let mapViewController = main_storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        let rootNavigation = UINavigationController.init(rootViewController:mapViewController)
        
        //Init reveal View Controller
        //Left View Controller
        let contactViewController = main_storyboard.instantiateViewController(withIdentifier: "ContactViewController") as! ContactViewController
        let friendListNavigation = UINavigationController.init(rootViewController:contactViewController)
        
        //Set reveal View Controller
        let drawerController = KYDrawerController(drawerDirection: .left, drawerWidth: screen_width - 80)
        drawerController.mainViewController = rootNavigation
        drawerController.drawerViewController = friendListNavigation
        return drawerController
    }
    
    func autoSignIn() {
        let userName = UserDefaults.standard.object(forKey: "userName") as? String
        if userName != nil {
            DatabaseManager.resetAllData(onCompletion: {_ in
                UserDefaults.standard.set(email, forKey: "userName")
                UserDefaults.standard.synchronize()
            })
        }
    }
}
