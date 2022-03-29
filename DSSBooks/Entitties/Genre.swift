//
//  Genre.swift
//  DSSBooks
//
//  Created by David on 11/03/22.
//

import Foundation
import ParseSwift

struct Genre: ParseObject {
    // Required properties from ParseObject protocol
    var originalData: Data?
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    
    var name: String?
    
    // Implement your own version of merge
    func merge(with object: Genre) throws -> Genre {
        var updated = try merge(with: object)
        
        if updated.shouldRestoreKey(\.name, original: object) { updated.name = object.name }
        
        return updated
    }
}
