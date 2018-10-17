//
//  Location.swift
//  PhotoMaps
//
//  Created by Fabio Giolito on 17/10/2018.
//  Copyright © 2018 Fabio Giolito. All rights reserved.
//

import Foundation
import MapKit

struct Location {
    let title: String
    let address: String
    
    let imageRef: String
    
    let latitude: Double
    let longitude: Double
    let dateTime: Date
    
    func coordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func mapItem() -> MKMapItem {
        return MKMapItem(placemark: MKPlacemark(coordinate: coordinate()))
    }
    
    func pin() -> MKPointAnnotation {
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate()
        pin.title = title
        pin.subtitle = address
        return pin
    }
}
