//
//  NewMapViewController.swift
//  PhotoMaps
//
//  Created by Fabio Giolito on 18/10/2018.
//  Copyright © 2018 Fabio Giolito. All rights reserved.
//

import UIKit
import Photos
import TLPhotoPicker

class NewMapViewController: UIViewController, TLPhotosPickerViewControllerDelegate {
    
    // =========================================
    // MODEL
    
    let map = Map.init(name: "", locations: [])
    
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
        navigationController?.isNavigationBarHidden = false
        layoutSubviews()
        
        // If map is empty, open picker automatically
        autoOpenPickerIfMapIsEmpty()
    }
    
    // =========================================
    // ACTION FUNCTIONS
    
    func autoOpenPickerIfMapIsEmpty() {
        if (map.locations.count == 0) {
            openPicker()
        }
    }
    
    func addButtonTapped() {
        openPicker()
    }
    
    // request photo library access and open picker
    func openPicker() {
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                let imagePicker = TLPhotosPickerViewController.custom()
                imagePicker.delegate = self
                self.present(imagePicker, animated: true, completion: nil)
            default:
                self.present(NoAccessViewController(), animated: true, completion: nil)
            }
        }
    }
    
    // finished picking images
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        print(withTLPHAssets)
    }

}
