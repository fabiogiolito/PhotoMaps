//
//  Map.swift
//  PhotoMaps
//
//  Created by Fabio Giolito on 17/10/2018.
//  Copyright © 2018 Fabio Giolito. All rights reserved.
//

import Foundation

struct Map: Codable {
    
    let id: Int
    let name: String
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
}
