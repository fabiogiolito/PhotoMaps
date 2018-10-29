//
//  Location.swift
//  PhotoMaps
//
//  Created by Fabio Giolito on 17/10/2018.
//  Copyright © 2018 Fabio Giolito. All rights reserved.
//

import Foundation
import MapKit
import Photos

struct Location: Codable, Equatable {

    var name: String
    var address: String
    var identifier: String
    var latitude: Double
    var longitude: Double
    var date: Date
    
    
    // =========================================
    // COMPUTED PROPERTIES
    
    var photoAsset: PHAsset? {
        get {
            let assets = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
            return assets.firstObject
        }
    }
    
    var coordinate: CLLocationCoordinate2D? {
        get {
            return photoAsset?.location?.coordinate
        }
    }
    
    var mapItem: MKMapItem? {
        get {
            guard let coordinate = coordinate else { return nil }
            return MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        }
    }
    
    var pin: MKPointAnnotation {
        get {
            let pin = MKPointAnnotation()
            guard let coordinate = coordinate else { return pin }
            pin.coordinate = coordinate
            return pin
        }
    }
    
    var image: UIImage {
        get {
            return UIImage.fromAsset(photoAsset, size: 400)
        }
    }
    
    // ==========================
    // FUNCTIONS
    
    func toJson() -> Data? {
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(self) {
            return jsonData
        }
        return nil
    }
    
//    func fetchReverseGeocodeAddress() {
//
//        guard let photoAsset = photoAsset else { return }
//        guard let location = photoAsset.location else { return }
//
//        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
//            if let error = error {
//                print("error on reverse geocode location: ", error)
//                return
//            }
//            guard let placemark = placemarks?.first else {
//                print("no placemarks returned on reverse geocode location")
//                return
//            }
//
//            let streetNumber = placemark.subThoroughfare ?? ""
//            let streetName = placemark.thoroughfare ?? ""
//
//            DispatchQueue.main.async {
//                address = "\(streetNumber) \(streetName)"
//                print("returned geocode: ", address)
//            }
//        }
//    }

}
