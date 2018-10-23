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
    // SUBVIEWS
    
    let imageView: UIImageView = {
        let imgView = UIImageView()
        imgView.clipsToBounds = true
        imgView.contentMode = .scaleAspectFill
        return imgView
    }()
    
    lazy var deleteButton: UIButton = {
        let btn = UIButton.icon(image: UIImage(named: "deleteDot") ?? UIImage())
        btn.layer.borderColor = UIColor.white.cgColor
        btn.layer.borderWidth = 2
        btn.layer.cornerRadius = 16
        btn.addTarget(self, action: #selector(didTapDeleteButton(_:)), for: .touchUpInside)
        return btn
    }()
    
    var delegate: PhotoCellDelegate!
    
    // =========================================
    // INITIALIZERS
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        imageView.fillSuperview()
        
        addSubview(deleteButton)
        deleteButton.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: -14, paddingLeft: 4, paddingBottom: 0, paddingRight: 0, width: 32, height: 32)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // =========================================
    // FUNCTIONS
    
    @objc func didTapDeleteButton(_ sender: AnyObject?) {
        guard let index = sender?.tag else { return }
        delegate.deletePhotoFromStrip(index: index)
    }
    
}

// PROTOCOL
protocol PhotoCellDelegate {
    func deletePhotoFromStrip(index: Int) -> Void
}
