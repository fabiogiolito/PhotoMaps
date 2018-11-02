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
    var map: Map!

    
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
    
    let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .gray)
        spinner.startAnimating()
        return spinner
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

        recenterMapButton.anchor(top: nil, left: nil, bottom: mapView.bottomAnchor, right: mapView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 8, paddingRight: 8, width: 32, height: 32)
    }
    
    // =========================================
    // MARK:- LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        photoStripCollectionView.photoStripDelegate = self
        
        title = map.name
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)
        
        layoutSubviews()
        loadDataOnMap()
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
        var pins: [MKPointAnnotation] = []
        
        DispatchQueue.global(qos: .background).async {
            for location in self.map.locations {
                pins.append(location.pin)
            }
            DispatchQueue.main.async {
                self.mapView.addAnnotations(pins)
                self.focusOnAnnotations(pins)
                self.requestRoutes()
            }
        }
    }
    
    // Request route
    func requestRoutes() {
        var polylines: [MKPolyline] = []
        
        DispatchQueue.global(qos: .background).async {
            for (index, location) in self.map.locations.enumerated() {
                
                if index != 0 {
                    let request = MKDirections.Request()
                    
                    // Define points
                    request.source = self.map.locations[index - 1].mapItem
                    request.destination = location.mapItem
                    
                    // Define transport type
                    request.transportType = .walking
                    
                    // Calculate directions
                    let directions = MKDirections(request: request)
                    directions.calculate { (response, error) in
                        if error != nil {
                            print("Error calculating route:", error ?? "")
                        }
                        guard let response = response else { return }
                        guard let route = response.routes.first else { return }
                        polylines.append(route.polyline)
                    }
                }
            }
            DispatchQueue.main.async {
                self.mapView.addOverlays(polylines)
                self.spinner.stopAnimating()
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
