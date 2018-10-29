//
//  Buttons.swift
//  WhiLight
//
//  Created by Fabio Giolito on 10/20/17.
//  Copyright © 2017 weheartit. All rights reserved.
//

import UIKit

extension UIButton {
    
    // Button styles
    
    static func base() -> UIButton {
        let button = UIButton(type: .system)
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.backgroundColor = .white
        button.tintColor = UIColor.grayDark()
        button.layer.borderColor = UIColor.shadowLight().cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 4
        return button
    }
    
    static func large() -> UIButton {
        let button = UIButton.base()
        button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 24, bottom: 16, right: 24)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.backgroundColor = UIColor.primary()
        button.tintColor = .white
        button.layer.borderWidth = 0
        button.layer.cornerRadius = 10
        return button
    }
    
    static func primary() -> UIButton {
        let button = UIButton.base()
        button.backgroundColor = UIColor.primary()
        button.tintColor = .white
        button.layer.borderWidth = 0
        return button
    }
    
    static func secondary() -> UIButton {
        let button = UIButton.base()
        button.tintColor = UIColor.primary()
        return button
    }
    
    static func tertiary() -> UIButton {
        let button = UIButton.base()
        return button
    }
    
    static func quaternary() -> UIButton {
        let button = UIButton.base()
        button.backgroundColor = UIColor.offWhite()
        button.layer.borderWidth = 0
        return button
    }
    
    static func danger() -> UIButton {
        let button = UIButton.base()
        button.backgroundColor = UIColor.danger()
        button.layer.borderWidth = 0
        button.tintColor = .white
        return button
    }
    
    static func label(font: UIFont = UIFont.caption()) -> UIButton {
        let button = UIButton.base()
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        button.titleLabel?.font = font
        button.backgroundColor = .clear
        button.layer.borderWidth = 0
        return button
    }
    
    static func icon(image: UIImage, tintColor: UIColor = UIColor.grayDark()) -> UIButton {
        let button = UIButton(type: .system)
        button.tintColor = tintColor
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }
    
    static func vertical(title: String, icon: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.caption()
        button.tintColor = UIColor.grayLight()
        
        var insets = button.titleEdgeInsets
        insets.bottom = -32
        button.titleEdgeInsets = insets
        
        let image = UIImageView(image: UIImage(named: icon))
        image.contentMode = .center
        button.addSubview(image)
        
        image.anchor(top: button.topAnchor, left: button.leftAnchor, bottom: button.centerYAnchor, right: button.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: -24, paddingRight: 0, width: 0, height: 0)
        
        return button
    }

}
