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
    
    
    // ==========================
    // FUNCTIONS
    
    func toJson() -> Data? {
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(self) {
            return jsonData
        }
        return nil
    }
    
    func fetchImage(_ forSize: CGFloat = 500, _ completion: @escaping ((_ image: UIImage) -> Void)) {
        guard let asset = photoAsset else { return }
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat
        manager.requestImage(for: asset, targetSize: CGSize(width: forSize, height: forSize), contentMode: .aspectFill, options: options) { (result, info) in
            if let result = result {
                completion(result)
            }
        }
    }
}
