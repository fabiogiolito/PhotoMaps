//
//  AccessDeniedViewController.swift
//  PhotoMaps
//
//  Created by Fabio Giolito on 18/10/2018.
//  Copyright © 2018 Fabio Giolito. All rights reserved.
//

import UIKit

class AccessDeniedViewController: UIViewController {
    
    // =========================================
    // SUBVIEWS

    let image: UIImageView = {
        let img = UIImageView(image: UIImage(named: "map_lost"))
        img.anchorSquare(ratio: 0.8)
        return img
    }()
    
    let bodyLabel: UILabel = {
        let label = UILabel()
        label.text = "The app needs access to your photo library so you can see your photos on a map."
        label.numberOfLines = 0
        label.textAlignment = .center
        label.setLineHeight(lineHeight: 10)
        return label
    }()
    
    let openSettingsButton: UIButton = {
        let btn = UIButton.large()
        btn.setTitle("Open Settings", for: .normal)
        btn.addTarget(self, action: #selector(openSettingsButtonTapped(_:)), for: .touchUpInside)
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
        
        let buttonStack = UIStackView(arrangedSubviews: [ openSettingsButton, explainerLabel ])
        buttonStack.axis = .vertical
        buttonStack.spacing = 24
        
        let stack = UIStackView(arrangedSubviews: [ image, bodyLabel, buttonStack ])
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        
        view.addSubview(stack)
        
        stack.fillSuperview(paddingVertical: 24, paddingHorizontal: 40)
    }
    
    // =========================================
    // LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .white
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // =========================================
    // ACTION FUNCTIONS
    
    @objc func openSettingsButtonTapped(_ sender: AnyObject?) {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }
    
}
