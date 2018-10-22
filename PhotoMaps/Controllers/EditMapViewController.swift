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
            showEmptyStateIfNoLocations()
        }
    }
    
    enum Section: Int {
        case attributes = 0
        case locations
        static let count = 2
    }
    
    enum CellIdentifier: String {
        case locationItem
    }

    
    // =========================================
    // SUBVIEWS
    
    lazy var addPhotosButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addPhotosButtonTapped(_:)))
        return btn
    }()
    
    lazy var previewMapButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(previewMapButtonTapped(_:)))
        return btn
    }()
    
    lazy var emptyStateView: EmptyStateView = {
        let empty = EmptyStateView(frame: self.view.frame)
        empty.titleLabel.text = "No photos"
        empty.bodyLabel.text = "Tap the + button to add some photos and build your map"
        return empty
    }()
    
    
    // =========================================
    // LAYOUT SUBVIEWS
    func layoutSubviews() {
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = false
        navigationItem.rightBarButtonItems = [previewMapButton, addPhotosButton]
        title = "Map"
    }
    
    // =========================================
    // LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutSubviews()
        
        // Register cells
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellIdentifier.locationItem.rawValue)
        
        // If map is empty, open picker automatically
         autoOpenPickerIfMapIsEmpty()
    }
    

    // =========================================
    // TABLE VIEW DATA SOURCE
    
    // Number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count
    }
    
    // Number of cells
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .attributes:
            return 1
        case .locations:
            return map.locations.count
        }
    }
    
    // Provide a footer view to remove placeholder lines on tableview
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch Section(rawValue: section)! {
        case .attributes:
            return nil
            
        case .locations:
            return UIView()
        }
    }
    
    // Build cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .attributes:
            let cell = UITableViewCell()
            cell.textLabel?.text = map.name
            return cell
        
        case .locations:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.locationItem.rawValue, for: indexPath)
            let location = map.locations[indexPath.row]
            cell.textLabel?.text = location.name
            cell.imageView?.image = location.image
            return cell
        }
    }
    
    // Selected cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Section(rawValue: indexPath.section)! {
        case .attributes:
            print("selected attribute")
            
        case .locations:
            print("selected image")
        }
    }
    
    
    // =========================================
    // ACTION FUNCTIONS
    
    // Tapped button to add photos
    @objc func addPhotosButtonTapped(_ sender: AnyObject?) {
        openPicker()
    }
    
    // Tapped button to preview map
    @objc func previewMapButtonTapped(_ sender: AnyObject?) {
        let mapViewController = MapViewController()
        mapViewController.map = map
        navigationController?.pushViewController(mapViewController, animated: true)
    }
    
    // Open image picker if map has no images yet
    func autoOpenPickerIfMapIsEmpty() {
        if map.locations.count == 0 {
            openPicker()
        }
    }
    
    // Request photo library access and open picker
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
    
    // Finished picking images, add them to map
    func dismissPhotoPicker(withPHAssets: [PHAsset]) {
        addPhotosToMap(assets: withPHAssets)
    }

    // Add photos to map
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
    
    // Show empty state
    func showEmptyStateIfNoLocations() -> Void {
        if map.locations.count > 0 {
            self.tableView.backgroundView = nil
        } else {
            self.tableView.backgroundView = emptyStateView
        }
    }
}
