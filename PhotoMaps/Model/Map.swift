//
//  Map.swift
//  PhotoMaps
//
//  Created by Fabio Giolito on 17/10/2018.
//  Copyright © 2018 Fabio Giolito. All rights reserved.
//

import Foundation
import MapKit

struct Map: Codable {
    
    var id: Int
    var name: String
    var locations: [Location] 
    
    // ==========================
    // FUNCTIONS
    
    func toJson() -> Data? {
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(self) {
            return jsonData
        }
        return nil
    }
    
    // Find location index from coordinates
    func findLocationIndexFromCoordinates(_ coordinates: CLLocationCoordinate2D) -> Int? {
        let latlong = "\(coordinates.latitude),\(coordinates.longitude)"
        for (index, location) in locations.enumerated() {
            guard
                let latitude = location.coordinate?.latitude,
                let longitude = location.coordinate?.longitude
                else { return nil }
            if latlong == "\(latitude),\(longitude)" {
                return index
            }
        }
        return nil
    }
    
    // Find location index from asset Identifier
    func findLocationIndexFromAssetIdentifier(_ identifier: String) -> Int? {
        for (index, location) in locations.enumerated() {
            if location.identifier == identifier {
                return index
            }
        }
        return nil
    }
}
