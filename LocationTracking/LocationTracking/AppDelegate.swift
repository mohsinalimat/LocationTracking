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
import Firebase
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var firebaseObject  = FirebaseAction()
    var refHandler      = DatabaseReference()
    var profile         = ContactModel()
    var contactArray    = [ContactModel]()
    var groupArray      = [GroupModel]()
    var locationArray   = [LocationModel]()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //Set up Google API Key
        GMSServices.provideAPIKey("AIzaSyB-vkbuoB24Hb8StdNS_mw4VaAN7oiZMe0")
        GMSPlacesClient.provideAPIKey("AIzaSyB-vkbuoB24Hb8StdNS_mw4VaAN7oiZMe0")
        
        //Init Firebase
        firebaseObject.initFirebase()
        
        GADMobileAds.configure(withApplicationID: kApplicationId)
        
        //Auto Signin
        self.autoSignIn()

        return true
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
    
    //MARK: - Sign in
    func autoSignIn() {
        let userName = UserDefaults.standard.object(forKey: "userName") as? String
        let password = UserDefaults.standard.object(forKey: "password") as? String
        
        if userName != nil && password != nil {
            self.firebaseObject.signInWith(email: userName!, name:nil, password: password!, completionHandler: {(isSuccess) in
                
                if let visibleViewController = Common.getVisibleViewController(UIApplication.shared.keyWindow?.rootViewController) as? OriginalViewController {
                    
                    if !(visibleViewController is SignInViewController) {return}
                    
                    if (isSuccess) {                        
                        //SignIn is successful
                        let mapViewController = main_storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
                        let nav = UINavigationController.init(rootViewController: mapViewController)
                        
                        visibleViewController.present(nav, animated: true, completion: nil)
                    }
                    visibleViewController.hideHUD()
                }
            })
        } else {
            let rootViewController = self.window?.rootViewController as! OriginalViewController
            rootViewController.hideHUD()
        }
    }
}
