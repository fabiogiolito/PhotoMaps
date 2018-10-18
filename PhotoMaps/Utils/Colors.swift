//
//  Colors.swift
//  WhiLight
//
//  Created by Fabio Giolito on 9/27/17.
//  Copyright © 2017 weheartit. All rights reserved.
//

import UIKit

extension UIColor {
    
    // App colors
    
    static func primary() -> UIColor {
        return UIColor.rgb(red: 0, green: 122, blue: 255)
    }
    
    static func grayDark() -> UIColor {
        return UIColor.rgb(red: 61, green: 72, blue: 82)
    }
    
    static func grayLight() -> UIColor {
        return UIColor.rgb(red: 135, green: 149, blue: 161)
    }
    
    static func offWhite() -> UIColor {
        return UIColor.rgb(red: 241, green: 245, blue: 248)
    }

    static func shadowLight() -> UIColor {
        return UIColor(white: 0, alpha: 0.1)
    }
    
    static func shadowDark() -> UIColor {
        return UIColor(white: 0, alpha: 0.5)
    }
    
    
    // Color helpers
    
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }

    
}
