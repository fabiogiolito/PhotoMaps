//
//  InitialViewController.swift
//  PhotoMaps
//
//  Created by Fabio Giolito on 17/10/2018.
//  Copyright © 2018 Fabio Giolito. All rights reserved.
//

import UIKit

class AccessPromptViewController: UIViewController {
    
    // =========================================
    // MARK:- SUBVIEWS

    let image: UIImageView = {
        let img = UIImageView(image: UIImage(named: "map_illustration"))
        img.anchorSquare(ratio: 0.8)
        return img
    }()
    
    let appNameLabel: UILabel = {
        let label = UILabel()
        label.text = "PhotoMaps"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 40, weight: .heavy)
        return label
    }()
    
    let bodyLabel: UILabel = {
        let label = UILabel()
        label.text = "View your photos on a map \nRetrace your steps \nCreate photo guides"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.setLineHeight(lineHeight: 10)
        return label
    }()
    
    let accessPhotosButton: UIButton = {
        let btn = UIButton.large()
        btn.setTitle("Get Started", for: .normal)
        btn.addTarget(self, action: #selector(accessPhotosButtonTapped(_:)), for: .touchUpInside)
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
    // MARK:- LAYOUT SUBVIEWS
    func layoutSubviews() {
        
        let buttonStack = UIStackView(arrangedSubviews: [ accessPhotosButton, explainerLabel ])
        buttonStack.axis = .vertical
        buttonStack.spacing = 24

        let stack = UIStackView(arrangedSubviews: [ image, appNameLabel, bodyLabel, buttonStack ])
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        
        view.addSubview(stack)
        
        stack.anchorSize(width: 270, height: 520)
        stack.anchorCenterIn(view)

    }
    
    // =========================================
    // MARK:- LIFECYCLE
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
    // MARK:- ACTION FUNCTIONS

    @objc func accessPhotosButtonTapped(_ sender: AnyObject?) {
        present(UINavigationController(rootViewController: MapListViewController()), animated: true, completion: nil)
    }

}
