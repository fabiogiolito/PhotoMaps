//
//  EditMapViewController.swift
//  PhotoMaps
//
//  Created by Fabio Giolito on 28/10/2018.
//  Copyright © 2018 Fabio Giolito. All rights reserved.
//

import UIKit
import MapKit
import TLPhotoPicker
import Photos

class EditMapViewController: UITableViewController, TLPhotosPickerViewControllerDelegate {
    
    // =========================================
    // MODEL
    
    var userData = UserData.init()
    var map: Map! {
        didSet {
            title = map.name
            showEmptyStateIfNoLocations()
            userData.maps[map.id] = map // Update data
            tableView.reloadData() // Reload data
        }
    }
    
    enum Section: Int {
        case actions
        case locations
        static let count = 2
    }
    
    enum Action: Int {
        case view
        case share
        case rename
        static let count = 3
    }
    
    enum CellIdentifier: String {
        case inputCell, locationCell
    }
    
    // =========================================
    // SUBVIEWS
    
    lazy var addPhotosButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addPhotosButtonTapped(_:)))
        return btn
    }()

    lazy var emptyStateView: EmptyStateView = {
        let empty = EmptyStateView()
        empty.titleLabel.text = "No Photos"
        empty.bodyLabel.text = "Tap the + button to add some photos"
        return empty
    }()
    
    lazy var renameMapPrompt: UIAlertController = {
        let alert = UIAlertController(title: "Map Name", message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let save = UIAlertAction(title: "Save", style: .default, handler: { (_) in
            guard let mapNameField = alert.textFields?[0] else { return }
            self.updateMapName(name: mapNameField.text)
        })
        alert.addAction(cancel)
        alert.addAction(save)
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "your map name…"
            textField.text = self.map.name
        })
        return alert
    }()
    
    
    // =========================================
    // LAYOUT SUBVIEWS
    
    func layoutSubviews() {
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = false
    }
    
    
    // =========================================
    // LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutSubviews()
        
        navigationItem.rightBarButtonItems = [addPhotosButton]
        
        // Register cells
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellIdentifier.inputCell.rawValue)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellIdentifier.locationCell.rawValue)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        title = map.name
    }
    

    // =========================================
    // TABLE VIEW DATA SOURCE
    
    // Number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count
    }
    
    // Number of maps
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .actions:
            return Action.count
        case .locations:
            return map.locations.count
        }
    }
    
    // Build cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .actions:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.inputCell.rawValue, for: indexPath)
            cell.textLabel?.textColor = UIColor.primary()
            
            switch Action(rawValue: indexPath.row)! {
            case .view:
                cell.textLabel?.text = "View map"
                cell.imageView?.image = UIImage.init(named: "icon_map")
                cell.accessoryType = .disclosureIndicator

            case .share:
                cell.textLabel?.text = "Share map"
                cell.imageView?.image = UIImage.init(named: "icon_share")
            
            case .rename:
                cell.textLabel?.text = "Rename map"
                cell.imageView?.image = UIImage.init(named: "icon_edit")
            }
            return cell

        case .locations:
            var cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.locationCell.rawValue) as? LocationCell
            if (cell == nil) {
                cell = LocationCell.init(style: .default, reuseIdentifier: CellIdentifier.locationCell.rawValue) as LocationCell
            }
            cell?.location = map.locations[indexPath.row]
            return cell!
        }
    }
    
    // Selected a map
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Section(rawValue: indexPath.section)! {
        case .actions:
            switch Action(rawValue: indexPath.row)! {
            case .view:
                let mapVC = MapViewController()
                mapVC.map = map
                title = ""
                navigationController?.pushViewController(mapVC, animated: true)
                
            case .share:
                print("Share map")
            
            case .rename:
                present(renameMapPrompt, animated: true)
            }
            
        case .locations:
            print("location tapped", indexPath.row)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Provide a footer view to remove placeholder lines on tableview
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return section == 1 ? UIView() : nil
    }
    
    // Make cells deletable
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1
    }
    
    // Edit cell: delete
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            map.locations.remove(at: indexPath.row)
        }
    }
    
    
    // =========================================
    // MODEL FUNCTIONS
    
    // Perform name update
    func updateMapName(name: String?) {
        guard let name = name else { return } // Make sure we have a name
        map.name = name // Update map name, triggers save and refresh
    }

    
    // =========================================
    // PICKER FUNCTIONS
    
    // Open image picker if map has no images yet
    func autoOpenPickerIfMapIsEmpty() -> Void {
        if map.locations.count == 0 {
            openPicker()
        }
    }
    
    // Open photo picker (check status, request permission)
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
    
    // Finished picking images, save data
    func dismissPhotoPicker(withPHAssets: [PHAsset]) {
        for asset in withPHAssets {
            
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
    
    // =========================================
    // ACTION FUNCTIONS
    
    // Tapped Add button on navbar
    @objc func addPhotosButtonTapped(_ sender: AnyObject?) {
        openPicker()
    }
    
    
    // =========================================
    // HELPER FUNCTIONS

    // Show empty state
    func showEmptyStateIfNoLocations() -> Void {
        if map.locations.count > 0 {
            self.tableView.backgroundView = nil
        } else {
            self.tableView.backgroundView = emptyStateView
            self.tableView.backgroundView?.fillSuperview()
        }
    }

}
