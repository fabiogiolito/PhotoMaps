//
//  String.swift
//  PhotoMaps
//
//  Created by Fabio Giolito on 23/10/2018.
//  Copyright © 2018 Fabio Giolito. All rights reserved.
//

import Foundation

extension String {
    
    func pluralize(count: Int = 0, with: String? = nil, hideCount: Bool = false) -> String {
        let plural = with ?? "\(self)s"
        let word = count == 1 ? self : plural
        
        return hideCount ? word : "\(count) \(word)"
    }
}
