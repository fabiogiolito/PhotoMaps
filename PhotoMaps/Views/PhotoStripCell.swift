//
//  PhotoStripCell.swift
//  PhotoMaps
//
//  Created by Fabio Giolito on 23/10/2018.
//  Copyright © 2018 Fabio Giolito. All rights reserved.
//

import UIKit

class PhotoStripCell: UICollectionViewCell {
    
    // =========================================
    // MARK:- MODEL
    
    var location: Location! {
        didSet {
            location.fetchImage(forSize: frame.width) { (image) in
                self.imageView.image = image
            }
            locationName.text = location.name == "" ? " " : location.name
            locationAddress.text = location.address == "" ? " " : location.address
        }
    }
    
    // =========================================
    // MARK:- SUBVIEWS
    
    let imageView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "image_placeholder")!
        imgView.clipsToBounds = true
        imgView.contentMode = .scaleAspectFill
        imgView.layer.cornerRadius = 2
        return imgView
    }()
    
    let locationName: UILabel = {
        let label = UILabel()
        label.font = UIFont.body()
        return label
    }()
    
    let locationAddress: UILabel = {
        let label = UILabel()
        label.font = UIFont.displayTextSmall()
        return label
    }()
    
    
    // =========================================
    // MARK:- INITIALIZERS
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let stackView = UIStackView(arrangedSubviews: [locationName, locationAddress, imageView])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.setCustomSpacing(8, after: locationAddress)
        
        addSubview(stackView)
        stackView.fillSuperview()
        
        imageView.anchorSquare(ratio: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
