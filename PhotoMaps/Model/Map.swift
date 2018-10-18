//
//  Map.swift
//  PhotoMaps
//
//  Created by Fabio Giolito on 17/10/2018.
//  Copyright © 2018 Fabio Giolito. All rights reserved.
//

import Foundation

struct Map: Codable {
    let name: String
    var locations: [Location]
    
    
    // ==========================
    // FUNCTIONS
    
    func toJson() -> String {
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(self)
            return String(data: jsonData, encoding: .utf8)!
        } catch {
            print("error decoding")
        }
        return "{}"
    }
}
