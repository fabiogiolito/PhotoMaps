//
//  InitialViewController.swift
//  PhotoMaps
//
//  Created by Fabio Giolito on 17/10/2018.
//  Copyright © 2018 Fabio Giolito. All rights reserved.
//

import UIKit
import Photos

class InitialViewController: UIViewController {
    
    // SUBVIEWS

    let image: UIImageView = {
        let img = UIImageView(image: UIImage(named: "map_illustration"))
        return img
    }()
    
    // LAYOUT SUBVIEWS
    func layoutSubviews() {
        
    }
    
    // LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkPhotosPermission()
        layoutSubviews()
        
    }
    
    func checkPhotosPermission() {
        // Case has permission: goToNextView()
        // Case no permission: Ask permission
        // -> Permission granted: goToNextView()
        // -> Permission declined Alert
    }
    
    func goToNextView() {
        // -> If maps: segue maps list
        // -> Else: segue picker
    }
    
}
