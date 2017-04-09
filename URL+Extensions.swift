//
//  URL+Extensions.swift
//  MatchboxDropbox
//
//  Created by Neil Skinner on 08/04/2017.
//  Copyright © 2017 Neil Skinner. All rights reserved.
//

import Foundation

extension URL {
    
    /**
    grabs all the query fragments of an URL
     */
    var fragments: [String: String] {
        var results = [String: String]()
        if let items = self.fragment?.components(separatedBy: "&"), items.count > 0 {
            for item: String in items {
                if let fragment = item.components(separatedBy: "=") as [String]? {
                    results.updateValue(fragment[1], forKey: fragment[0])
                }
            }
        }
        return results
    }
}
