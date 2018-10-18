//
//  MapListViewController.swift
//  PhotoMaps
//
//  Created by Fabio Giolito on 18/10/2018.
//  Copyright © 2018 Fabio Giolito. All rights reserved.
//

import UIKit

class MapListViewController: UIViewController {
    
    // =========================================
    // SUBVIEWS

    
    // =========================================
    // LAYOUT SUBVIEWS
    func layoutSubviews() {
    }
    
    // =========================================
    // LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Layout
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = true
        layoutSubviews()
    }
    
    // =========================================
    // ACTION FUNCTIONS

}
