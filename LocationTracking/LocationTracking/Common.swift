//
//  Common.swift
//  LocationTracking
//
//  Created by Nguyen Hai Dang on 6/17/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit

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
}
