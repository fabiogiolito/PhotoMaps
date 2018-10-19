//
//  MapViewController.swift
//  PhotoMaps
//
//  Created by Fabio Giolito on 19/10/2018.
//  Copyright © 2018 Fabio Giolito. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    // =========================================
    // MODEL
    
    var map: Map!
    
    // Options for photo strip drag animation
    enum DragOptions: CGFloat {
        case maxLimit = -400
        case minLimit = -140
        case maximized = -350
        case minimized = -150
    }
    var photoStripTopConstraint: NSLayoutConstraint?
    var photoStripTopConstraintInitialConstant: CGFloat = DragOptions.minimized.rawValue
    
    
    // =========================================
    // SUBVIEWS
    
    lazy var navbarOptionsButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.action, target: self, action: #selector(navbarOptionsButtonTapped(_:)))
        return btn
    }()

    lazy var mapView: MKMapView = {
        let map = MKMapView(frame: view.bounds)
        return map
    }()
    
    lazy var photoStripContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDragPhotoStrip)))
        view.layer.masksToBounds = false
        view.layer.shadowOffset = CGSize(width: 0, height: -1)
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    lazy var photoStripCollectionView: PhotoStripCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        let view = PhotoStripCollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        view.isPagingEnabled = true
        view.map = self.map
        return view
    }()
    
    
    // =========================================
    // LAYOUT SUBVIEWS
    
    func layoutSubviews() {
        
        // Basic layout
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = false
        navigationItem.rightBarButtonItems = [navbarOptionsButton]
        title = map.name
        
        view.addSubview(mapView)
        view.addSubview(photoStripContainer)
        
        photoStripContainer.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: view.bounds.height)
        
        photoStripTopConstraint = photoStripContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: DragOptions.minimized.rawValue)
        photoStripTopConstraint?.isActive = true
        
        photoStripContainer.addSubview(photoStripCollectionView)
        photoStripCollectionView.anchor(top: photoStripContainer.topAnchor, left: photoStripContainer.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: photoStripContainer.rightAnchor, paddingTop: 16, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)

        // Put locations on map and request routes
        for (index, location) in map.locations.enumerated() {
            mapView.addAnnotation(location.pin)
            if index > 0 {
                requestRoute(source: map.locations[index - 1], destination: location)
            }
        }
        
        // Zoom to fit annotations
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    // =========================================
    // LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutSubviews()
        mapView.delegate = self
    }

    
    // =========================================
    // ACTION FUNCTIONS
    
    // Tapped "more" button on navbar
    @objc func navbarOptionsButtonTapped(_ sender: AnyObject?) {
        print("navbar options button tapped")
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
            print("velocity: ", velocity)

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
}

// =========================================
// MAP VIEW DELEGATE FUNCTIONS
extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        renderer.lineWidth = 1
        return renderer
    }
    
    //    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    //        let annotationIdentifier = "pinView"
    //
    //        var annotationView: MKAnnotationView?
    //        if let dequeueAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
    //            annotationView = dequeueAnnotationView
    //            annotationView?.annotation = annotation
    //        } else {
    //            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
    //        }
    //
    //        if let annotationView = annotationView {
    ////            annotationView.canShowCallout = true
    //        }
    //
    //        return annotationView
    //
    //    }
}
