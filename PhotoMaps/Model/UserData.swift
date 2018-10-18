//
//  UserData.swift
//  PhotoMaps
//
//  Created by Fabio Giolito on 18/10/2018.
//  Copyright © 2018 Fabio Giolito. All rights reserved.
//

import Foundation

struct UserData: Codable {
    
    var maps: [Map] {
        didSet {
            saveToDefaults()
        }
    }

    // ==========================
    // INITIALIZERS
    
    // Initialize from UserDefaults
    init() {
        self.maps = []
        let defaults = UserDefaults.standard
        
        // Uncomment and run to clear user defaults
        // defaults.removeObject(forKey: "UserData")
        
        if let userData = defaults.object(forKey: "UserData") as? Data {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode(UserData.self, from: userData) {
                self.maps = decoded.maps
                
                print("UserDefaults loaded, ", self)
            }
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
    
    func saveToDefaults() -> Void {
        let defaults = UserDefaults.standard
        if let data = self.toJson() {
            defaults.set(data, forKey: "UserData")
        }
        print("===== DEFAULTS UPDATED =====")
    }
}
