//
//  Gradient.swift
//  WhiLight
//
//  Created by Fabio Giolito on 11/6/17.
//  Copyright © 2017 weheartit. All rights reserved.
//

import UIKit

class GradientView: UIView {
    
    public var startColor: UIColor = .white {
        didSet {
            gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
            setNeedsDisplay()
        }
    }
    
    public var endColor: UIColor = .white {
        didSet {
            gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
            setNeedsDisplay()
        }
    }
    
    private lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = [self.startColor.cgColor, self.endColor.cgColor]
        return gradientLayer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    open override func layoutSubviews() {
        gradientLayer.frame = bounds
    }
}
