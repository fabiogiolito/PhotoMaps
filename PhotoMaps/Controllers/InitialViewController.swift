//
//  InitialViewController.swift
//  PhotoMaps
//
//  Created by Fabio Giolito on 17/10/2018.
//  Copyright © 2018 Fabio Giolito. All rights reserved.
//

import UIKit
import Photos
import TLPhotoPicker

class InitialViewController: UIViewController, TLPhotosPickerViewControllerDelegate {
    
    // =========================================
    // SUBVIEWS

    let image: UIImageView = {
        let img = UIImageView(image: UIImage(named: "map_illustration"))
        img.anchorSquare(ratio: 0.8)
        return img
    }()
    
    let appNameLabel: UILabel = {
        let label = UILabel()
        label.text = "PhotoMap"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 40)
        label.font = UIFont.systemFont(ofSize: 40, weight: .heavy)
        return label
    }()
    
    let featureListLabel: UILabel = {
        let label = UILabel()
        label.text = "View your photos on a map \nRetrace your steps \nCreate photo guides"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.setLineHeight(lineHeight: 10)
        return label
    }()
    
    let accessButton: UIButton = {
        let btn = UIButton.large()
        btn.setTitle("Access Photos", for: .normal)
        btn.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
        return btn
    }()
    
    let explainerLabel: UILabel = {
        let label = UILabel()
        label.text = "It's all done on your device, your photos and information are not uploaded to our servers."
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.displayTextSmall()
        label.textColor = UIColor.grayLight()
        return label
    }()
    
    
    // =========================================
    // LAYOUT SUBVIEWS
    func layoutSubviews() {
        
        let buttonStack = UIStackView(arrangedSubviews: [ accessButton, explainerLabel ])
        buttonStack.axis = .vertical
        buttonStack.spacing = 24

        let stack = UIStackView(arrangedSubviews: [ image, appNameLabel, featureListLabel, buttonStack ])
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        
        view.addSubview(stack)
        
        stack.fillSuperview(paddingVertical: 24, paddingHorizontal: 40)
    }
    
    // =========================================
    // LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set layout basics
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = true
        
        checkPhotosPermission()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        layoutSubviews()
    }

    
    // =========================================
    // SETUP FUNCTIONS

    func checkPhotosPermission() {
    }
    
    func goToNextView() {
    }
    
    
    // =========================================
    // ACTION FUNCTIONS

    @objc func buttonClicked(_ sender: AnyObject?) {
        
        let imagePicker = TLPhotosPickerViewController()
        imagePicker.delegate = self
        
        var configure = TLPhotosPickerConfigure()
        configure.usedCameraButton = false
        configure.numberOfColumn = 4
        configure.nibSet = (nibName: "CustomImagePickerCell", bundle: Bundle.main)
        imagePicker.configure = configure
        
        self.present(imagePicker, animated: true, completion: nil)
    }

    // finished picking images
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        print(withTLPHAssets)
    }

}
