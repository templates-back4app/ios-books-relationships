//
//  MainController+ParseSwift.swift
//  DSSBooks
//
//  Created by David on 14/03/22.
//

import Foundation
import ParseSwift

extension MainController {
    /// Collects the data to save an instance of Book on your Back4App database.
    func saveBook() {
        view.endEditing(true)
        
        // 1. First retrieve all the information for the Book (bookTitle, isbnValue, etc)
        guard let bookTitle = bookTitleTextField.text else {
            return presentAlert(title: "Error", message: "Invalid book title")
        }
        
        guard let isbnValue = isbnTextField.text else {
            return presentAlert(title: "Error", message: "Invalid ISBN value.")
        }
        
        let query = ISBN.query("value" == isbnValue)
        
        guard (try? query.first()) == nil else {
            return presentAlert(title: "Error", message: "The entered ISBN already exists.")
        }
        
        guard let genreObjectId = genreOptionsView.selectedOptionIds.first,
              let genre = genres.first(where: { $0.objectId == genreObjectId})
        else {
            return presentAlert(title: "Error", message: "Invalid genre.")
        }
        
        guard let publishingYearString = publishingYearTextField.text, let publishingYear = Int(publishingYearString) else {
            return presentAlert(title: "Error", message: "Invalid publishing year.")
        }
        
        let authors: [Author] = self.authorOptionsView.selectedOptionIds.compactMap { [weak self] objectId in
            self?.authors.first(where: { objectId == $0.objectId })
        }
        
        let publishers: [Publisher] = self.publisherOptionsView.selectedOptionIds.compactMap { [weak self] objectId in
            self?.publishers.first(where: { objectId == $0.objectId })
        }
        
        // Since we are making multiple requests to Back4App, it is better to use synchronous methods and dispatch them on the background queue
        DispatchQueue.global(qos: .background).async {
            do {
                let isbn = ISBN(value: isbnValue) // 2. Instantiate a new ISBN object
                
                let savedBook = try Book( // 3. Instantiate a new Book object with the corresponding input fields
                    title: bookTitle,
                    publishingYear: publishingYear,
                    genre: genre,
                    isbn: isbn
                ).save() // 4. Save the new Book object
                
                // 5. Add the corresponding relations for new Book object
                guard let bookToAuthorsRelation = try savedBook.relation?.add("authors", objects: authors), // Book -> Author
                      let bootkToPublishersRelation = try savedBook.relation?.add("publishers", objects: publishers), // Book -> Publisher
                      let genreRelation = try genre.relation?.add("books", objects: [savedBook]) // Genre -> Book
                else {
                    return DispatchQueue.main.async {
                        self.presentAlert(title: "Error", message: "Failed to add relations")
                    }
                }
                                
                // 6. Save the relations
                _ = try bookToAuthorsRelation.save()
                _ = try bootkToPublishersRelation.save()
                _ = try genreRelation.save()
                
                DispatchQueue.main.async {
                    self.presentAlert(title: "Success", message: "Book saved successfully.")
                }
            } catch {
                DispatchQueue.main.async {
                    self.presentAlert(title: "Error", message: "Failed to save book: \((error as! ParseError).message)")
                }
            }
        }
    }
    
    /// Retrieves all the data saved under the Genre class in your Back4App Database
    func fetchGenres() {
        let query = Genre.query()
        
        query.find { [weak self] result in
            switch result {
            case .success(let genres):
                self?.genres = genres // When setting self?.genres, it triggers the corresponding UI update
            case .failure(let error):
                self?.presentAlert(title: "Error", message: error.message)
            }
        }
    }
    
    /// Presents a simple alert where the user can enter the name of a genre to save it on your Back4App Database
    func handleAddGenre() {
        // Displays a form with a single input and executes the completion block when the user presses the submit button
        presentForm(
            title: "Add genre",
            description: "Enter a description for the genre",
            placeholder: nil
        ) { [weak self] name in
            guard let name = name else { return }
            let genre = Genre(name: name)
            
            let query = Genre.query("name" == name)
            
            guard ((try? query.first()) == nil) else {
                self?.presentAlert(title: "Error", message: "This genre already exists.")
                return
            }
            
            genre.save { [weak self] result in
                switch result {
                case .success(let addedGenre):
                    self?.presentAlert(title: "Success", message: "Genre added!")
                    self?.genres.append(addedGenre)
                case .failure(let error):
                    self?.presentAlert(title: "Error", message: "Failed to save genre: \(error.message)")
                }
            }
        }
    }
    
    /// Retrieves all the data saved under the Publisher class in your Back4App Database
    func fetchPublishers() {
        let query = Publisher.query()
        
        query.find { [weak self] result in
            switch result {
            case .success(let publishers):
                self?.publishers = publishers
            case .failure(let error):
                self?.presentAlert(title: "Error", message: error.message)
            }
        }
    }
    
    /// Presents a simple alert where the user can enter the name of a publisher to save it on your Back4App Database
    func handleAddPublisher() {
        // Displays a form with a single input and executes the completion block when the user presses the submit button
        presentForm(
            title: "Add publisher",
            description: "Enter the name of the publisher",
            placeholder: nil
        ) { [weak self] name in
            guard let name = name else { return }
            
            let query = Publisher.query("name" == name)
            
            guard ((try? query.first()) == nil) else {
                self?.presentAlert(title: "Error", message: "This publisher already exists.")
                return
            }
            
            let publisher = Publisher(name: name)
            
            publisher.save { [weak self] result in
                switch result {
                case .success(let addedPublisher):
                    self?.presentAlert(title: "Success", message: "Publisher added!")
                    self?.publishers.append(addedPublisher)
                case .failure(let error):
                    self?.presentAlert(title: "Error", message: "Failed to save publisher: \(error.message)")
                }
            }
        }
    }
    
    /// Retrieves all the data saved under the Genre class in your Back4App Database
    func fetchAuthors() {
        let query = Author.query()
        
        query.find { [weak self] result in
            switch result {
            case .success(let authors):
                self?.authors = authors
            case .failure(let error):
                self?.presentAlert(title: "Error", message: error.message)
            }
        }
    }
    
    /// Presents a simple alert where the user can enter the name of an author to save it on your Back4App Database
    func handleAddAuthor() {
        // Displays a form with a single input and executes the completion block when the user presses the submit button
        presentForm(
            title: "Add author",
            description: "Enter the name of the author",
            placeholder: nil
        ) { [weak self] name in
            guard let name = name else { return }
            
            let query = Author.query("name" == name)
            
            guard ((try? query.first()) == nil) else {
                self?.presentAlert(title: "Error", message: "This author already exists.")
                return
            }
            
            let author = Author(name: name)
            
            author.save { [weak self] result in
                switch result {
                case .success(let addedAuthor):
                    self?.presentAlert(title: "Success", message: "Author added!")
                    self?.authors.append(addedAuthor)
                case .failure(let error):
                    self?.presentAlert(title: "Error", message: "Failed to save author: \(error.message)")
                }
            }
        }
    }
}
