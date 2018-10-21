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
    
    var userData = UserData.init()
    var map: Map! {
        didSet {
            userData.maps[map.id] = map
            tableView.reloadData()
        }
    }
    
    let locationItemCellId = "LocationItem"
    
    // =========================================
    // SUBVIEWS
    
    lazy var navbarAddButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(navbarAddButtonTapped(_:)))
        return btn
    }()
    
    
    // =========================================
    // LAYOUT SUBVIEWS
    func layoutSubviews() {
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = false
        navigationItem.rightBarButtonItems = [navbarAddButton]
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
        // autoOpenPickerIfMapIsEmpty()
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
            let location = map.locations[indexPath.row]
            cell.textLabel?.text = location.name
            cell.imageView?.image = location.image
            return cell
        }
        let cell = UITableViewCell()
        cell.textLabel?.text = map.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected image, should allow to edit title, address…")
    }
    
    
    // =========================================
    // ACTION FUNCTIONS
    
    func addPhotosToMap(assets: [PHAsset]) {
        for asset in assets {
            
            guard let latitude = asset.location?.coordinate.latitude else { return }
            guard let longitude = asset.location?.coordinate.longitude else { return }
            guard let date = asset.creationDate else { return }
            
            // Create new location
            let location = Location.init(
                name: "New location",
                address: "Add address",
                identifier: asset.localIdentifier,
                latitude: latitude,
                longitude: longitude,
                date: date
            )

            // Update data
            var locations = self.map.locations // get current locatiosn
            locations.append(location) // append new location
            let sortedLocations = locations.sorted { $0.date < $1.date } // sort locations list by date
            self.map.locations = sortedLocations // update map locations with sorted list
        }
    }
    
    @objc func navbarAddButtonTapped(_ sender: AnyObject?) {
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
        addPhotosToMap(assets: withPHAssets)
        goBackToAccessPromptIfNewUserDidNotSelectPhotos(withPHAssets)
    }
    
    // canceled picker
    func photoPickerDidCancel() {
        goBackToAccessPromptIfNewUserDidNotSelectPhotos()
    }
    
    // check if didn't select anything or canceled
    func goBackToAccessPromptIfNewUserDidNotSelectPhotos(_ selection: [PHAsset] = []) {
        // No selection, and map is empty
        if selection.count == 0 && map.locations.count == 0 {

            // Has other maps: Go to MapList
            if userData.maps.count > 0 {
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
