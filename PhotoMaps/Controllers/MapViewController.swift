//
//  MapViewController.swift
//  PhotoMaps
//
//  Created by Fabio Giolito on 19/10/2018.
//  Copyright © 2018 Fabio Giolito. All rights reserved.
//

import UIKit
import MapKit
import Photos

class MapViewController: UIViewController, PhotoStripDelegate, MKMapViewDelegate {

    // =========================================
    // MARK:- MODEL
    
    var userData = UserData.init()
    var map: Map! {
        didSet {
            photoStripCollectionView.map = map // load photo strip
            loadDataOnMap() // load map pins
        }
    }

    
    // =========================================
    // MARK:- SUBVIEWS
    
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
        layout.sectionInset = UIEdgeInsets(top: 16, left: 24, bottom: 24, right: 70)
        let cv = PhotoStripCollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        cv.map = self.map
        return cv
    }()
    
    lazy var recenterMapButton: UIButton = {
        let btn = UIButton.icon(image: UIImage(named: "icon_recenter")!)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 16
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.shadowLight().cgColor
        btn.tintColor = UIColor.grayLight()
        btn.addTarget(self, action: #selector(recenterMapButtonTapped(_:)), for: .touchUpInside)
        return btn
    }()
    
    
    // =========================================
    // MARK:- LAYOUT SUBVIEWS
    
    func layoutSubviews() {
        
        // Basic layout
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = false
        
        view.addSubview(mapView)
        view.addSubview(recenterMapButton)
        view.addSubview(photoStripContainer)
        photoStripContainer.addSubview(photoStripCollectionView)
        
        photoStripContainer.anchor(top: photoStripCollectionView.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        photoStripCollectionView.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        photoStripCollectionView.anchorSquare(ratio: 1)
        
        mapView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: photoStripContainer.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)

        recenterMapButton.anchor(top: mapView.topAnchor, left: nil, bottom: nil, right: mapView.rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 32, height: 32)
    }
    
    // =========================================
    // MARK:- LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutSubviews()
        mapView.delegate = self
        photoStripCollectionView.photoStripDelegate = self
        loadDataOnMap()
        title = map.name
    }

    
    // =========================================
    // MARK:- ACTION FUNCTIONS
    
    @objc func recenterMapButtonTapped(_ sender: AnyObject?) {
        focusOnAnnotations(mapView.annotations)
    }
    
    // =========================================
    // MARK:- MAP FUNCTIONS
    
    // Fill map
    func loadDataOnMap() {
        mapView.removeAnnotations(mapView.annotations) // Remove all annotations to start over
        mapView.removeOverlays(mapView.overlays) // Remove all overlays to start over
        
        // Add locations
        for (index, location) in map.locations.enumerated() {
            mapView.addAnnotation(location.pin)
            if index > 0 {
                // Add routes
                requestRoute(source: map.locations[index - 1], destination: location)
            }
        }
        
        // Zoom to fit annotations
        focusOnAnnotations(mapView.annotations)
    }
    
    // Request route
    func requestRoute(source: Location, destination: Location) {
        
        // Ignore if different days
        if source.date.description.prefix(10) != destination.date.description.prefix(10) {
            return
        }
        
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
        renderer.strokeColor = UIColor.primary()
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
    
    // Custom Pins
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pinImage = UIImageView(image: UIImage(named: "pin")!)
        let view = MKAnnotationView(annotation: annotation, reuseIdentifier: "test")
        view.frame.size = CGSize(width: 24, height: 32)
        view.centerOffset = CGPoint(x: 0, y: -13)
        view.addSubview(pinImage)
        pinImage.fillSuperview()
        return view
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
