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
    
    // =========================================
    // SUBVIEWS
    
    lazy var mapView: MKMapView = {
        let map = MKMapView(frame: self.view.bounds)
        return map
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
