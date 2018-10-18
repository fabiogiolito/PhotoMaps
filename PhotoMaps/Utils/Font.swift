//
//  Font.swift
//  WhiLight
//
//  Created by Fabio Giolito on 10/31/17.
//  Copyright © 2017 weheartit. All rights reserved.
//

import UIKit

extension UIFont {
    
    static func body() -> UIFont {
        return preferredFont(forTextStyle: .callout)
    }
    
    static func displayTextStrong() -> UIFont {
        return UIFont.systemFont(ofSize: 14, weight: .semibold)
    }
    
    static func displayTextSmall() -> UIFont {
        return UIFont.systemFont(ofSize: 12)
    }
    
    static func caption() -> UIFont {
        return UIFont.systemFont(ofSize: 12, weight: .semibold)
    }
    
}
