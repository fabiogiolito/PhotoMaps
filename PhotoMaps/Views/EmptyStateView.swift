//
//  EmptyStateView.swift
//  PhotoMaps
//
//  Created by Fabio Giolito on 21/10/2018.
//  Copyright © 2018 Fabio Giolito. All rights reserved.
//

import UIKit

class EmptyStateView: UIView {
    
    
    // =========================================
    // SUBVIEWS
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "No content yet"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = UIColor.grayLight()
        label.numberOfLines = 0
        return label
    }()
    
    let bodyLabel: UILabel = {
        let label = UILabel()
        label.text = "Nothing to display"
        label.textAlignment = .center
        label.setLineHeight(lineHeight: 10)
        label.textColor = UIColor.grayLight()
        label.numberOfLines = 0
        return label
    }()
    
    
    // =========================================
    // INITIALIZERS
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        addSubview(bodyLabel)

        titleLabel.anchor(top: nil, left: leftAnchor, bottom: centerYAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 40, paddingBottom: 12, paddingRight: 40, width: 0, height: 0)
        bodyLabel.anchor(top: centerYAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 12, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 0)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
