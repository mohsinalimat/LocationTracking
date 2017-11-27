//
//  APIManager.swift
//  LocationTracking
//
//  Created by Hai Dang Nguyen on 11/27/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import GoogleMaps

class APIManager: NSObject {

    static func getDirectionPath (startLat: Double, startLong: Double, DesLat: Double, DesLong: Double, onComplehandler: @escaping ([JSON]) -> ()) {
        let origin = "\(startLat),\(startLong)"
        let destination = "\(DesLat),\(DesLong)"
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving"
        
        Alamofire.request(url).responseJSON { response in
            
            print(response.request as Any)  // original URL request
            print(response.response as Any) // HTTP URL response
            print(response.data as Any)     // server data
            print(response.result as Any)   // result of response serialization
            
            let json = JSON(data: response.data!)
            let routes = json["routes"].arrayValue
            
            onComplehandler(routes)
            // print route using Polyline
//            for route in routes
//            {
//                let routeOverviewPolyline = route["overview_polyline"].dictionary
//                let points = routeOverviewPolyline?["points"]?.stringValue
//                let path = GMSPath.init(fromEncodedPath: points!)
//                let polyline = GMSPolyline.init(path: path)
//                polyline.strokeWidth = 4
//                polyline.strokeColor = UIColor.red
//            polyline.map = self.googleMaps
//
//            }
            
        }
    }
}
