//
//  ISBN.swift
//  DSSBooks
//
//  Created by David on 11/03/22.
//

import Foundation
import ParseSwift

struct ISBN: ParseObject {
    // Required properties from ParseObject protocol
    var originalData: Data?
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    
    var value: String?
    
    // Implement your own version of merge
    func merge(with object: ISBN) throws -> ISBN {
        var updated = try merge(with: object)
        
        if updated.shouldRestoreKey(\.value, original: object) { updated.value = object.value }
                
        return updated
    }
}
