//
//  LocationCell.swift
//  PhotoMaps
//
//  Created by Fabio Giolito on 29/10/2018.
//  Copyright © 2018 Fabio Giolito. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell {
    
    // =========================================
    // MODEL
    
    var location: Location! {
        didSet {
            thumbnailView.image = location.image
            locationNameLabel.text = location.name
            locationAddressLabel.text = location.address
        }
    }
    
    
    // =========================================
    // SUBVIEWS
    
    let thumbnailView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        return img
    }()

    let locationNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.body()
        return label
    }()

    let locationAddressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.displayTextSmall()
        return label
    }()

    
    // =========================================
    // INITIALIZER
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        separatorInset = UIEdgeInsets(top: 0, left: 96, bottom: 0, right: 0)
        
        addSubview(thumbnailView)
        thumbnailView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        
        let stackView = UIStackView(arrangedSubviews: [UIView(), locationNameLabel, locationAddressLabel, UIView()])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fill
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leftAnchor.constraint(equalTo: thumbnailView.rightAnchor, constant: 16).isActive = true
        stackView.centerYAnchor.constraint(equalTo: thumbnailView.centerYAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
