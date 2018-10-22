//
//  MapViewController.swift
//  PhotoMaps
//
//  Created by Fabio Giolito on 19/10/2018.
//  Copyright © 2018 Fabio Giolito. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, CollectionViewMapTarget {
    
    // =========================================
    // MODEL
    
    var map: Map!
    
    var visibleAnnotations: [MKAnnotation]? {
        didSet {
            guard let annotations = visibleAnnotations else { return }
            mapView.showAnnotations(annotations, animated: true)
        }
    }
    
    // Options for photo strip drag animation
    enum DragOptions: CGFloat {
        case maxLimit = -400
        case minLimit = -140
        case maximized = -350
        case minimized = -340 // Should be -150, but disabling minimization for now
    }
    var photoStripTopConstraint: NSLayoutConstraint?
    var photoStripTopConstraintInitialConstant: CGFloat = DragOptions.minimized.rawValue
    
    
    // =========================================
    // SUBVIEWS
    
    lazy var editMapButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.edit, target: self, action: #selector(editMapButtonTapped(_:)))
        return btn
    }()

    lazy var mapView: MKMapView = {
        let map = MKMapView()
        return map
    }()
    
    lazy var photoStripContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.isUserInteractionEnabled = true
        // Commented out, disabling maximizing collection view for now, animation too choppy
        // view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDragPhotoStrip)))
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
        navigationItem.rightBarButtonItems = [editMapButton]
        title = map.name
        
        view.addSubview(mapView)
        view.addSubview(photoStripContainer)
        photoStripContainer.addSubview(photoStripCollectionView)
        
        mapView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: photoStripContainer.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        photoStripContainer.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: view.bounds.height)
        
        photoStripTopConstraint = photoStripContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: DragOptions.minimized.rawValue)
        photoStripTopConstraint?.isActive = true
        
        photoStripCollectionView.anchor(top: photoStripContainer.topAnchor, left: photoStripContainer.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: photoStripContainer.rightAnchor, paddingTop: 24, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        photoStripCollectionView.mapTargetDelegate = self

    }
    
    // =========================================
    // LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutSubviews()
        addLocationsToMap()
        mapView.delegate = self
    }

    
    // =========================================
    // ACTION FUNCTIONS

    // Fill map
    func addLocationsToMap() {
        // Put locations on map and request routes
        for (index, location) in map.locations.enumerated() {
            mapView.addAnnotation(location.pin)
            if index > 0 {
                requestRoute(source: map.locations[index - 1], destination: location)
            }
        }
        
        // Zoom to fit annotations
        visibleAnnotations = mapView.annotations
    }
    
    // Tapped "more" button on navbar
    @objc func editMapButtonTapped(_ sender: AnyObject?) {
        let editMapController = EditMapViewController()
        editMapController.map = map
        navigationController?.pushViewController(editMapController, animated: true)
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
    
    
    // Drag photo strip animation
    @objc func handleDragPhotoStrip(gesture: UIPanGestureRecognizer) {
        
        // IS DRAGGING
        if gesture.state == .changed {
            
            // Get Y translation, limit at dragLimit
            var translation = gesture.translation(in: self.view).y + photoStripTopConstraintInitialConstant
            if translation < DragOptions.maxLimit.rawValue { translation = DragOptions.maxLimit.rawValue }
            if translation > DragOptions.minLimit.rawValue { translation = DragOptions.minLimit.rawValue }
            
            // Apply translation
            photoStripTopConstraint?.constant = translation
            self.photoStripCollectionView.setNeedsLayout()
            self.photoStripCollectionView.collectionViewLayout.invalidateLayout()
            
        // ENDED DRAGGING
        } else if gesture.state == .ended {
            
            // Get Y translation, limit at dragLimit
            var translation = gesture.translation(in: self.photoStripContainer).y + photoStripTopConstraintInitialConstant
            if translation < DragOptions.maxLimit.rawValue { translation = DragOptions.maxLimit.rawValue }
            if translation > DragOptions.minLimit.rawValue { translation = DragOptions.minLimit.rawValue }
            
            // Get gesture velocity
            let velocity = gesture.velocity(in: self.photoStripContainer).y

            // Setup final positions
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {

                // Stay at maximized position
                if translation < DragOptions.maxLimit.rawValue / 2 || velocity < -500 {
                    self.photoStripTopConstraint?.constant = DragOptions.maximized.rawValue
                    self.photoStripTopConstraintInitialConstant = DragOptions.maximized.rawValue
                    
                    // Go back to minimized position
                } else {
                    self.photoStripTopConstraint?.constant = DragOptions.minimized.rawValue
                    self.photoStripTopConstraintInitialConstant = DragOptions.minimized.rawValue
                }
                
                // Animate
                self.view.layoutIfNeeded()
                self.photoStripCollectionView.collectionViewLayout.invalidateLayout()
            })
        }
    }
    
    // Recenter map on specific annotation
    func recenterMap(index: Int) {
        visibleAnnotations = [map.locations[index].pin]
    }

}

// =========================================
// MAP VIEW DELEGATE FUNCTIONS
extension MapViewController: MKMapViewDelegate {
    
    // Render route line on map
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        renderer.lineWidth = 1
        return renderer
    }

}
