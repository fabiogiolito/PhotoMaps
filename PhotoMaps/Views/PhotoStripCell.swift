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
    // MARK:- SUBVIEWS
    
    let imageView: UIImageView = {
        let imgView = UIImageView()
        imgView.clipsToBounds = true
        imgView.contentMode = .scaleAspectFill
        return imgView
    }()

    
    // =========================================
    // MARK:- INITIALIZERS
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        imageView.fillSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
