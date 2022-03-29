//
//  Book.swift
//  DSSBooks
//
//  Created by David on 11/03/22.
//

import Foundation
import ParseSwift

struct Book: ParseObject {
    // Required properties from ParseObject protocol
    var originalData: Data?
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    
    var title: String?
    var publishingYear: Int?
    var genre: Genre?
    var isbn: ISBN? // Esablishes a 1:1 relation between Book and ISBN
    
    // Implement your own version of merge
    func merge(with object: Book) throws -> Book {
        var updated = try merge(with: object)
        
        if updated.shouldRestoreKey(\.title, original: object) { updated.title = object.title }
        
        if updated.shouldRestoreKey(\.publishingYear, original: object) {
            updated.publishingYear = object.publishingYear
        }
        
        if updated.shouldRestoreKey(\.genre, original: object) {
            updated.genre = object.genre
        }
        
        if updated.shouldRestoreKey(\.isbn, original: object) {
            updated.isbn = object.isbn
        }
        
        return updated
    }
}
