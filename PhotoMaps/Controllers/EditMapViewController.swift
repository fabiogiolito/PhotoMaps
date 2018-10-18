//
//  EditMapViewController.swift
//  PhotoMaps
//
//  Created by Fabio Giolito on 18/10/2018.
//  Copyright © 2018 Fabio Giolito. All rights reserved.
//

import UIKit
import Photos
import TLPhotoPicker

class EditMapViewController: UITableViewController, TLPhotosPickerViewControllerDelegate {
    
    // =========================================
    // MODEL
    
    var map = Map.init(name: "New Map", locations: [])
    
    let locationItemCellId = "LocationItem"
    
    // =========================================
    // SUBVIEWS
    
    lazy var addButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addPhotosButtonTapped(_:)))
        return btn
    }()
    
    
    // =========================================
    // LAYOUT SUBVIEWS
    func layoutSubviews() {
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = false
        navigationItem.rightBarButtonItems = [addButton]
        title = "Map"
    }
    
    // =========================================
    // LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutSubviews()
        
        // Register cells
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: locationItemCellId)
        
        // If map is empty, open picker automatically
//        autoOpenPickerIfMapIsEmpty()
    }
    
    // =========================================
    // TABLE VIEW DATA SOURCE
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return map.locations.count
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: locationItemCellId, for: indexPath)
            cell.textLabel?.text = map.locations[indexPath.row].name
            return cell
        }
        let cell = UITableViewCell()
        cell.textLabel?.text = map.name
        return cell
    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//    }
    
    
    // =========================================
    // ACTION FUNCTIONS
    
    @objc func addPhotosButtonTapped(_ sender: AnyObject?) {
        openPicker()
    }
    
    func autoOpenPickerIfMapIsEmpty() {
        if map.locations.count == 0 {
            openPicker()
        }
    }
    
    // request photo library access and open picker
    func openPicker() {
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                let imagePicker = TLPhotosPickerViewController.custom()
                imagePicker.delegate = self
                DispatchQueue.main.async {
                    self.present(imagePicker, animated: true, completion: nil)
                }
            default:
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(AccessDeniedViewController(), animated: true)
                }
            }
        }
    }
    
    // finished picking images
    func dismissPhotoPicker(withPHAssets: [PHAsset]) {
        
        // add selected photos to map
        if withPHAssets.count > 0 {
            self.map.locations.append(Location.init(name: "Yo", address: "", imageRef: "", latitude: 0.0, longitude: 0.0, dateTime: Date()))
        }
        print(withPHAssets)
        goBackToAccessPromptIfNewUserDidNotSelectPhotos(withPHAssets)
    }
    
    // canceled picker
    func photoPickerDidCancel() {
        print("canceled")
        goBackToAccessPromptIfNewUserDidNotSelectPhotos()
    }
    
    // check if didn't select anything or canceled
    func goBackToAccessPromptIfNewUserDidNotSelectPhotos(_ selection: [PHAsset] = []) {
        // No selection, and map is empty
        if selection.count == 0 && map.locations.count == 0 {

            let userMaps = false
            
            // Has other maps: Go to MapList
            if userMaps {
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(MapListViewController(), animated: true)
                }

            // No maps: Go to AccessPrompt
            } else {
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(AccessPromptViewController(), animated: true)
                }
            }
        }
    }

}
