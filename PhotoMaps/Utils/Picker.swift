//
//  Picker.swift
//  PhotoMaps
//
//  Created by Fabio Giolito on 18/10/2018.
//  Copyright © 2018 Fabio Giolito. All rights reserved.
//

import TLPhotoPicker

extension TLPhotosPickerViewController {
    
    static func custom() -> TLPhotosPickerViewController {
        let imagePicker = TLPhotosPickerViewController()
        
        var configure = TLPhotosPickerConfigure()
        configure.usedCameraButton = false
        configure.numberOfColumn = 4
        configure.nibSet = (nibName: "CustomImagePickerCell", bundle: Bundle.main)
        imagePicker.configure = configure
        
        return imagePicker
    }
    
}
