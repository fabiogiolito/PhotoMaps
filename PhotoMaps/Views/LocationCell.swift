//
//  LocationCell.swift
//  PhotoMaps
//
//  Created by Fabio Giolito on 29/10/2018.
//  Copyright © 2018 Fabio Giolito. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell, UITextFieldDelegate {
    
    // =========================================
    // MARK:- MODEL
    
    var location: Location! {
        didSet {
            location.fetchImage(forSize: 80) { (image) in
                self.thumbnailView.image = image
            }
            locationNameLabel.text = location.name
            locationAddressLabel.text = location.address
        }
    }
    
    var dataDelegate: LocationCellDataDelegate!
    
    
    // =========================================
    // MARK:- SUBVIEWS
    
    let thumbnailView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "image_placeholder")!
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    lazy var locationNameLabel: UITextField = {
        let label = UITextField()
        label.placeholder = "Name"
        label.font = UIFont.body()
        label.delegate = self
        label.returnKeyType = UIReturnKeyType.next
        return label
    }()

    lazy var locationAddressLabel: UITextField = {
        let label = UITextField()
        label.placeholder = "Address"
        label.font = UIFont.displayTextSmall()
        label.delegate = self
        label.returnKeyType = .done
        return label
    }()

    
    // =========================================
    // MARK:- LAYOUT SUBVIEWS
    
    override func layoutSubviews() {
        separatorInset = UIEdgeInsets(top: 0, left: 96, bottom: 0, right: 0)
        
        addSubview(thumbnailView)
        addSubview(locationNameLabel)
        addSubview(locationAddressLabel)
        
        thumbnailView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        locationNameLabel.anchor(top: nil, left: thumbnailView.rightAnchor, bottom: thumbnailView.centerYAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 16, paddingBottom: 4, paddingRight: 24, width: 0, height: 0)
        locationAddressLabel.anchor(top: thumbnailView.centerYAnchor, left: thumbnailView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 4, paddingLeft: 16, paddingBottom: 0, paddingRight: 24, width: 0, height: 0)
    }
    
    // Clear image before reusing cell
    override func prepareForReuse() {
        thumbnailView.image = UIImage(named: "image_placeholder")!
    }
    
    
    // =========================================
    // MARK:- INITIALIZER
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        layoutSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // =========================================
    // MARK:- TEXTFIELD FUNCTIONS
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let value = textField.text else { return }
        if textField == locationNameLabel {
            location.name = value
        }
        if textField == locationAddressLabel {
            location.address = value
        }
        dataDelegate.updateLocation(location)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == locationNameLabel {
            locationAddressLabel.becomeFirstResponder()
        }
        return true
    }

}

protocol LocationCellDataDelegate {
    func updateLocation(_ location: Location)
}
