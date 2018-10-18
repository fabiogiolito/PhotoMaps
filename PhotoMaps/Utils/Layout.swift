//
//  Extensions.swift
//  WeHeartIt
//
//  Created by Fabio Giolito on 9/15/17.
//  Copyright © 2017 weheartit. All rights reserved.
//

import UIKit

extension UIView {
    
    // main auto layout helper
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?,  paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    // shorter auto layout helpers
    func anchorSize(width: CGFloat, height: CGFloat) {
        self.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: width, height: height)
    }
    
    func fillSuperview(paddingVertical: CGFloat = 0, paddingHorizontal: CGFloat = 0) {
        self.anchor(top: superview?.safeAreaLayoutGuide.topAnchor, left: superview?.safeAreaLayoutGuide.leftAnchor, bottom: superview?.safeAreaLayoutGuide.bottomAnchor, right: superview?.safeAreaLayoutGuide.rightAnchor, paddingTop: paddingVertical, paddingLeft: paddingHorizontal, paddingBottom: paddingVertical, paddingRight: paddingHorizontal, width: 0, height: 0)
    }
    
    func fillSuperviewWithSideMargins() {
        self.anchor(top: superview?.safeAreaLayoutGuide.topAnchor, left: superview?.layoutMarginsGuide.leftAnchor, bottom: superview?.safeAreaLayoutGuide.bottomAnchor, right: superview?.layoutMarginsGuide.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func anchorBelow(_ referenceAnchor: NSLayoutYAxisAnchor, height: CGFloat = 0) {
        self.anchor(top: referenceAnchor, left: superview?.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: superview?.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: height)
    }
    
    func anchorBelow(_ referenceAnchor: NSLayoutYAxisAnchor, height: CGFloat = 0, distance: CGFloat = 0) {
        self.anchor(top: referenceAnchor, left: superview?.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: superview?.safeAreaLayoutGuide.rightAnchor, paddingTop: distance, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: height)
    }

    func anchorBottom() {
        self.anchor(top: nil, left: nil, bottom: superview?.safeAreaLayoutGuide.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func anchorCenterX(_ anchor: NSLayoutXAxisAnchor) {
        self.centerXAnchor.constraint(equalTo: anchor, constant: 0).isActive = true
    }
    
    func anchorCenterY(_ anchor: NSLayoutYAxisAnchor) {
        self.centerYAnchor.constraint(equalTo: anchor, constant: 0).isActive = true
    }
    
    func anchorCenterIn(_ view: UIView) {
        self.anchorCenterX(view.centerXAnchor)
        self.anchorCenterY(view.centerYAnchor)
    }
    
    func anchorSquare(ratio: CGFloat = 1) {
        self.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: ratio).isActive = true
    }
    
}
