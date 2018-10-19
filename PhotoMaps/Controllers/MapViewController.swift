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
    
    enum DragOptions: CGFloat {
        case limit = -300
        case maximized = -250
        case minimized = 0
    }
    
    var currentTranslation: CGFloat = 0
    
    // =========================================
    // SUBVIEWS
    
    lazy var mapView: MKMapView = {
        let map = MKMapView(frame: view.bounds)
        return map
    }()
    
    lazy var photoStripContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDragPhotoStrip)))
        return view
    }()
    
    let blueView: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        return view
    }()

    
    // =========================================
    // LAYOUT SUBVIEWS
    
    func layoutSubviews() {
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = false
        // navigationItem.rightBarButtonItems = [addButton]
        // navigationItem.leftBarButtonItems = []
        title = map.name
        
        view.addSubview(mapView)
        view.addSubview(photoStripContainer)
        
        photoStripContainer.anchor(top: view.safeAreaLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: -150, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: view.bounds.height)
        
        photoStripContainer.addSubview(blueView)
        blueView.anchor(top: photoStripContainer.topAnchor, left: photoStripContainer.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: photoStripContainer.rightAnchor, paddingTop: 16, paddingLeft: 16, paddingBottom: 0, paddingRight: 16, width: 0, height: 0)

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
        
        // BEGAN DRAGGING
        if gesture.state == .began {
            print("Did begin dragging")
            
        // IS DRAGGING
        } else if gesture.state == .changed {
            
            // Get Y translation, limit at dragLimit
            var translation = gesture.translation(in: self.view).y + currentTranslation
            if translation < DragOptions.limit.rawValue { translation = DragOptions.limit.rawValue }
            
            print("is dragging: ", translation)
            
            // Apply translation
            photoStripContainer.transform = CGAffineTransform(translationX: 0, y: translation)
            
        // ENDED DRAGGING
        } else if gesture.state == .ended {
            
            // Get Y translation, limit at dragLimit
            var translation = gesture.translation(in: self.photoStripContainer).y + currentTranslation
            if translation < DragOptions.limit.rawValue { translation = DragOptions.limit.rawValue }
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {

                // Stay at maximized position
                if translation < DragOptions.limit.rawValue / 2 {
                    self.photoStripContainer.transform = CGAffineTransform(translationX: 0, y: DragOptions.maximized.rawValue)
                    self.currentTranslation = DragOptions.maximized.rawValue

                // Go back to minimized position
                } else {
                    self.photoStripContainer.transform = CGAffineTransform(translationX: 0, y: DragOptions.minimized.rawValue)
                    self.currentTranslation = DragOptions.minimized.rawValue
                }
                
                print(self.currentTranslation)
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
