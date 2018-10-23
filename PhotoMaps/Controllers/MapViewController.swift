//
//  MapViewController.swift
//  PhotoMaps
//
//  Created by Fabio Giolito on 19/10/2018.
//  Copyright © 2018 Fabio Giolito. All rights reserved.
//

import UIKit
import MapKit
import TLPhotoPicker
import Photos

class MapViewController: UIViewController, PhotoStripDelegate, TLPhotosPickerViewControllerDelegate, MKMapViewDelegate {
    
    // =========================================
    // MODEL
    
    var userData = UserData.init()
    var map: Map! {
        didSet {
            userData.maps[map.id] = map // update data
            photoStripCollectionView.map = map // update photo strip
            loadDataOnMap() // update map
            title = map.name // update map title on navbar
        }
    }


    // =========================================
    // SUBVIEWS
    
    lazy var addPhotosButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addPhotosButtonTapped(_:)))
        return btn
    }()

    lazy var editMapButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.edit, target: self, action: #selector(editMapButtonTapped(_:)))
        return btn
    }()
    
    lazy var editMapPrompt: UIAlertController = {
        let alert = UIAlertController(title: "Map Name", message: nil, preferredStyle: .alert)
        let create = UIAlertAction(title: "Save", style: .default, handler: { (_) in
            guard let mapNameField = alert.textFields?[0] else { return }
            self.updateMapName(name: mapNameField.text)
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "your map name…"
            textField.text = self.map.name
        })
        alert.addAction(create)
        alert.addAction(cancel)
        return alert
    }()

    lazy var mapView: MKMapView = {
        let map = MKMapView()
        return map
    }()
    
    lazy var photoStripContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.isUserInteractionEnabled = true
        view.layer.masksToBounds = false
        view.layer.shadowOffset = CGSize(width: 0, height: -1)
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    lazy var photoStripCollectionView: PhotoStripCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        let cv = PhotoStripCollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        cv.map = self.map
        return cv
    }()
    
    
    // =========================================
    // LAYOUT SUBVIEWS
    
    func layoutSubviews() {
        
        // Basic layout
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = false
        navigationItem.rightBarButtonItems = [addPhotosButton, editMapButton]
        
        view.addSubview(mapView)
        view.addSubview(photoStripContainer)
        photoStripContainer.addSubview(photoStripCollectionView)
        
        mapView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: photoStripContainer.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        photoStripContainer.anchor(top: view.safeAreaLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: -350, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 350)
        
        photoStripCollectionView.anchor(top: photoStripContainer.topAnchor, left: photoStripContainer.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: photoStripContainer.rightAnchor, paddingTop: 24, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    // =========================================
    // LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutSubviews()
        mapView.delegate = self
        photoStripCollectionView.photoStripDelegate = self
        loadDataOnMap()
        autoOpenPickerIfMapIsEmpty()
    }

    
    // =========================================
    // ACTION FUNCTIONS
    
    // Tapped "add" button on navbar
    @objc func addPhotosButtonTapped(_ sender: AnyObject?) {
        openPicker()
    }
    
    // Tapped "more" button on navbar
    @objc func editMapButtonTapped(_ sender: AnyObject?) {
        present(editMapPrompt, animated: true)
        // TODO: instead of presenting prompt, enter edit mode
        //   - show delete button on photos -> delete photo
        //   - show button to rename map -> opens prompt
    }
    
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
    // MAP FUNCTIONS
    
    // Fill map
    func loadDataOnMap() {
        // Remove any annotations to start over
        mapView.removeAnnotations(mapView.annotations)
        
        // Add locations
        for (index, location) in map.locations.enumerated() {
            mapView.addAnnotation(location.pin)
            if index > 0 {
                requestRoute(source: map.locations[index - 1], destination: location)
            }
        }
        
        // Zoom to fit annotations
        focusOnAnnotations(mapView.annotations)
    }
    
    // Request route
    func requestRoute(source: Location, destination: Location) {
        let request = MKDirections.Request()
        
        // Define points
        request.source = source.mapItem
        request.destination = destination.mapItem
        
        // Define transport types
        request.transportType = .walking
        
        // Calculate directions
        let directions = MKDirections(request: request)
        directions.calculate { [unowned self] (response, error) in
            guard let response = response else { return }
            for route in response.routes {
                self.mapView.addOverlay(route.polyline)
            }
        }
    }
    
    // Render route line on map
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        renderer.lineWidth = 1
        return renderer
    }
    
    // Selected annotation on map
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }
        
        // Center map on pin
        focusOnAnnotations([annotation])
        
        // Center photostrip on photo
        guard let index = map.findLocationIndexFromCoordinates(annotation.coordinate) else { return }
        
        let indexPath = IndexPath(row: index, section: 0)
        photoStripCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    // Move map to focus on pins
    func focusOnAnnotations(_ annotations: [MKAnnotation]) -> Void {
        mapView.showAnnotations(annotations, animated: true)
    }
    
    // Move map to focus on pins
    func focusOnLocationPin(index: Int) -> Void {
        mapView.showAnnotations([map.locations[index].pin], animated: true)
    }

}
