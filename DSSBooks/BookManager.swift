//
//  BookManager.swift
//  DSSBooks
//
//  Created by David on 12/03/22.
//

import Foundation
import ParseSwift

class BookManager {
    static let `default` = BookManager()
    
    func addGenre(name: String, completion: @escaping (Result<Genre, ParseError>) -> Void) {
        let genre = Genre(name: name)
        
        genre.save(completion: completion)
    }
    
    func addAuthor(name: String) {
        let author = Author(name: name)
        
        author.save { _ in
            
        }
    }
}
