//
//  Common.swift
//  LocationTracking
//
//  Created by Nguyen Hai Dang on 6/17/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps

class Common: NSObject {
    static func color(withRGB RGB: UInt) -> UIColor {
        return UIColor(red: CGFloat((RGB & 0xFF0000) >> 16) / 255.0,
                       green: CGFloat((RGB & 0x00FF00) >> 8) / 255.0,
                       blue: CGFloat(RGB & 0x0000FF) / 255.0,
                       alpha: 1.0)
    }
    
    static func mainColor() -> UIColor {
        return self.color(withRGB: 0x32A5DA)
    }
    
    static func getVisibleViewController(_ rootViewController: UIViewController?) -> UIViewController? {
        
        var rootVC = rootViewController
        if rootVC == nil {
            rootVC = UIApplication.shared.keyWindow?.rootViewController
        }
        
        if rootVC?.presentedViewController == nil {
            return rootVC
        }
        
        if let presented = rootVC?.presentedViewController {
            if presented.isKind(of: UINavigationController.self) {
                let navigationController = presented as! UINavigationController
                return navigationController.viewControllers.last!
            }
            if presented.isKind(of: UITabBarController.self) {
                let tabBarController = presented as! UITabBarController
                return tabBarController.selectedViewController!
            }
            return getVisibleViewController(presented)
        }
        return nil
    }
    
    static func convertToAddress(latitude: Double, longitude: Double, onCompletionHandler:@escaping (String) -> ()) {
        let geocoder = GMSGeocoder()
        var currentAddress = String()
        let coordinate = CLLocationCoordinate2DMake(latitude,longitude)

        geocoder.reverseGeocodeCoordinate(coordinate) { response , error in
            if let address = response?.firstResult() {
                let lines = address.lines! as [String]
                currentAddress = lines.joined(separator: "\n")
                onCompletionHandler(currentAddress)
            }
        }
    }
    
    static func getCurrentTimeStamp() -> String{
        let date = Date()
        let timestamp = date.timeIntervalSince1970 * 1000
        let timeString = String.init(format: "%.0f", timestamp)
        return timeString
    }
    
    static func setupLanguage() {
        //Set up Multi Language
        if kUserDefault.object(forKey: kLanguageCode) == nil {
            kUserDefault.set("en", forKey: kLanguageCode)
        }
        LocalizationSetLanguage(language: kUserDefault.object(forKey: kLanguageCode) as! String)
    }
}
