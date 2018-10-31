//
//  Images.swift
//  PhotoMaps
//
//  Created by Fabio Giolito on 18/10/2018.
//  Copyright © 2018 Fabio Giolito. All rights reserved.
//

import UIKit
import Photos

extension UIImage {
    
    static func fromAsset(_ asset: PHAsset?, size: CGFloat = 1024) -> UIImage {
        
        var image = UIImage(named: "image_placeholder")!
        guard let asset = asset else { return image }
        
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.isSynchronous = true
        option.isNetworkAccessAllowed = true
        option.deliveryMode = .highQualityFormat
        manager.requestImage(for: asset, targetSize: CGSize(width: size, height: size), contentMode: .aspectFill, options: option) { (result, info) in
            if let result = result {
                image = result
            }
        }
        return image
    }
    
}
