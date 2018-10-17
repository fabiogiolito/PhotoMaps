//
//  ViewController.swift
//  PhotoMaps
//
//  Created by Fabio Giolito on 16/10/2018.
//  Copyright © 2018 Fabio Giolito. All rights reserved.
//

import UIKit
import Photos
import MapKit

class ViewController: UIViewController {
    
    // SAMPLE DATA
    let data: Map = Map.init(name: "Madrid Centro", locations: [
        Location.init(
            title: "Mercado da Ribeira",
            address: "Av. 24 de Julho s/n",
            imageRef: "",
            latitude: 38.707060,
            longitude: -9.146965,
            dateTime: Date()
        ),
        Location.init(
            title: "Praça Luís de Camões",
            address: "Largo Luís de Camões",
            imageRef: "",
            latitude: 38.710878,
            longitude: -9.143155,
            dateTime: Date()
        ),
        Location.init(
            title: "Igreja de São Roque",
            address: "Largo Trindade Coelho",
            imageRef: "",
            latitude: 38.713695,
            longitude: -9.143203,
            dateTime: Date()
        ),
        Location.init(
            title: "Miradouro de São Pedro de Alcântara",
            address: "R. de São Pedro de Alcântara",
            imageRef: "",
            latitude: 38.715432,
            longitude: -9.144185,
            dateTime: Date()
        ),
    ])
    
    
    // SUBVIEWS
    lazy var mapView: MKMapView = {
        let map = MKMapView(frame: self.view.bounds)
        return map
    }()

    
    // VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mapView)
        mapView.delegate = self

        
//        PHPhotoLibrary.shared().register(self)
        
//        // FETCH PHOTOS
//        let allPhotosOptions = PHFetchOptions()
//        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
//        let allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
//        let photoObjects = allPhotos.objects(at: IndexSet(0...100))
//        let locations = photoObjects.compactMap { photo in photo.location?.coordinate }
    
//        // PUT LOCATIONS ON MAP AND CALCULATE ROUTES
//        for (index, location) in locations.enumerated() {
//            let pin = MKPointAnnotation()
//            pin.coordinate = location
//            pin.title = "Title"
//            pin.subtitle = "Subtitle"
//            mapView.addAnnotation(pin)
//            // request routes
//            if (index > 0) {
//                requestRoute(source: locations[index - 1], destination: location)
//            }
//        }
        
        
        // PUT LOCATIONS ON MAP AND REQUEST ROUTES
        for (index, location) in data.locations.enumerated() {
            mapView.addAnnotation(location.pin())
            if index > 0 {
                requestRoute(source: data.locations[index - 1], destination: location)
            }
        }
        
        // ZOOM TO FIT ANNOTATIONS
        mapView.showAnnotations(mapView.annotations, animated: true)
        
    }
    
    
    // REQUEST ROUTE
    func requestRoute(source: Location, destination: Location) {
        let request = MKDirections.Request()
        
        // Define points
        request.source = source.mapItem()
        request.destination = destination.mapItem()
        
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

// PHOTO LIBRARY OBSERVER FUNCTIONS
extension ViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
    }
}

// MAP VIEW DELEGATE FUNCTIONS
extension ViewController: MKMapViewDelegate {
    
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
