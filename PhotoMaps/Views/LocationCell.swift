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
            thumbnailView.image = location.image
            locationNameLabel.text = location.name
            locationAddressLabel.text = location.address
        }
    }
    
    var dataDelegate: LocationCellDataDelegate!
    
    
    // =========================================
    // MARK:- SUBVIEWS
    
    let thumbnailView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        return img
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
    // MARK:- INITIALIZER
    
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
