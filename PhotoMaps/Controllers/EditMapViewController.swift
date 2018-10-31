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

class EditMapViewController: UITableViewController, TLPhotosPickerViewControllerDelegate, LocationCellDataDelegate {
    
    // =========================================
    // MARK:- MODEL
    
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
    }
    
    enum CellIdentifier: String {
        case inputCell, locationCell
    }
    
    // =========================================
    // MARK:- SUBVIEWS
    
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
    
    let actionsStack: UIStackView = {
        let viewBtn = UIButton.vertical(title: "VIEW", icon: "icon_map")
        viewBtn.addTarget(self, action: #selector(viewButtonTapped(_:)), for: .touchUpInside)
        
        let shareBtn = UIButton.vertical(title: "SHARE", icon: "icon_share")
        shareBtn.addTarget(self, action: #selector(shareButtonTapped(_:)), for: .touchUpInside)
        
        let renameBtn = UIButton.vertical(title: "RENAME", icon: "icon_edit")
        renameBtn.addTarget(self, action: #selector(renameButtonTapped(_:)), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [viewBtn, shareBtn, renameBtn])
        stack.distribution = .fillEqually
        stack.tintColor = UIColor.grayLight()
        return stack
    }()
    
    
    // =========================================
    // MARK:- LAYOUT SUBVIEWS
    
    func layoutSubviews() {
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = false
    }
    
    
    // =========================================
    // MARK:- LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutSubviews()
        
        navigationItem.rightBarButtonItems = [addPhotosButton]
        
        // Register cells
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellIdentifier.inputCell.rawValue)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellIdentifier.locationCell.rawValue)
        
        autoOpenPickerIfMapIsEmpty()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = map.name
    }
    

    // =========================================
    // MARK:- TABLE VIEW DATA SOURCE
    
    // Number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count
    }
    
    // Number of maps
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .actions:
            return 1
        case .locations:
            return map.locations.count
        }
    }
    
    // Build cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .actions:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.inputCell.rawValue, for: indexPath)
            cell.addSubview(actionsStack)
            actionsStack.anchorSize(width: 0, height: 88)
            actionsStack.fillSuperview()
            return cell

        case .locations:
            var cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.locationCell.rawValue) as? LocationCell
            if (cell == nil) {
                cell = LocationCell.init(style: .default, reuseIdentifier: CellIdentifier.locationCell.rawValue) as LocationCell
            }
            cell?.location = map.locations[indexPath.row]
            cell?.dataDelegate = self
            return cell!
        }
    }
    
    // Selected a map
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Section(rawValue: indexPath.section)! {
        case .actions:
            break

        case .locations:
            guard let cell = tableView.cellForRow(at: indexPath) as? LocationCell else { return }
            cell.locationNameLabel.becomeFirstResponder()
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
    // MARK:- MODEL FUNCTIONS
    
    // Perform name update
    func updateMapName(name: String?) {
        guard let name = name else { return } // Make sure we have a name
        map.name = name // Update map name, triggers save and refresh
    }
    
    // Update Location
    func updateLocation(_ location: Location) {
        guard let coordinate = location.coordinate else { return }
        guard let index = map.findLocationIndexFromCoordinates(coordinate) else { return }
        userData.maps[map.id].locations[index] = location
    }
    
    // Try to fetch location Name and Address automatically
    func fetchLocationData(locations: [Location]) {
        for (index, location) in locations.enumerated() {
            var copyLocation = location
            guard let geocodeLocation = location.photoAsset?.location else { return }

            // if name or address is blank
            if copyLocation.name == "" || copyLocation.address == "" {
                
                // perform fetch for location data
                CLGeocoder().reverseGeocodeLocation(geocodeLocation) { (placemarks, error) in
                    if let error = error {
                        print("error on reverse geocode location: ", error)
                        return
                    }
                    guard let placemark = placemarks?.first else {
                        print("no placemarks returned on location address fetch")
                        return
                    }
                    
                    // Treat data
                    let name = placemark.name ?? ""
                    let streetNumber = placemark.subThoroughfare ?? ""
                    let streetName = placemark.thoroughfare ?? ""
                    let address = "\(streetNumber) \(streetName)".trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // Apply data
                    DispatchQueue.main.async {
                        if copyLocation.name == "" { // only update if name was blank
                            copyLocation.name = name
                        }
                        if copyLocation.address == "" { // only update if address was blank
                            copyLocation.address = address
                        }
                        self.map.locations[index] = copyLocation // apply changes
                        self.tableView.reloadData() // show changes
                    }
                }
            }
        }
    }

    
    // =========================================
    // MARK:- PICKER FUNCTIONS
    
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
            
            guard
                let latitude = asset.location?.coordinate.latitude,
                let longitude = asset.location?.coordinate.longitude
            else {
                print("no coordinates for selected asset")
                break
            }
            
            guard let date = asset.creationDate else {
                print("no date for selected asset")
                break
            }
            
            // Create new location
            let location = Location.init(
                name: "",
                address: "",
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
        
        // Try to fetch name and address
        fetchLocationData(locations: map.locations)
    }
    
    // =========================================
    // MARK:- ACTION FUNCTIONS
    
    // Tapped Add button on navbar
    @objc func addPhotosButtonTapped(_ sender: AnyObject?) {
        openPicker()
    }
    
    @objc func viewButtonTapped(_ sender: AnyObject?) {
        let mapVC = MapViewController()
        mapVC.map = userData.maps[map.id]
        title = ""
        navigationController?.pushViewController(mapVC, animated: true)
    }
    
    @objc func shareButtonTapped(_ sender: AnyObject?) {
        print("tapped share button")
    }
    
    @objc func renameButtonTapped(_ sender: AnyObject?) {
        present(renameMapPrompt, animated: true)
    }
    
    
    // =========================================
    // MARK:- HELPER FUNCTIONS

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
