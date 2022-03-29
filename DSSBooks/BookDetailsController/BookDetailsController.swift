//
//  BookDetailsController.swift
//  DSSBooks
//
//  Created by David on 23/03/22.
//

import UIKit
import ParseSwift

class AuthorCell: DetailCell<Author> {
    override func setup(model: Author) {
        textLabel?.text = model.name
    }
}

class PublisherCell: DetailCell<Publisher> {
    override func setup(model: Publisher) {
        textLabel?.text = model.name
    }
}

class BookDetailsController: UITableViewController {
    enum Section: Int, CaseIterable {
        case author = 0, publisher = 1
        
        var title: String {
            switch self {
            case .author: return "Authors"
            case .publisher: return "Publishers"
            }
        }
    }
    
    private var authors: [Author] = []
    private var publishers: [Publisher] = []
    
    let book: Book
    
    init(book: Book) {
        self.book = book
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchDetails()
        setupTableView()
    }
    
    /// Retrieves the book's details, i.e., its relation with authors and publishers
    private func fetchDetails() {
        do {
            // Constructs the relations you want to query
            let publishersQuery = try Publisher.queryRelations("publishers", parent: book)
            let authorsQuery = try Author.queryRelations("authors", parent: book)
            
            // Obtains the publishers related to book and display them on the tableView, it presents an error if happened.
            publishersQuery.find { [weak self] result in
                switch result {
                case .success(let publishers):
                    self?.publishers = publishers
                    
                    // Update the UI
                    DispatchQueue.main.async {
                        self?.tableView.reloadSections(IndexSet([Section.publisher.rawValue]), with: .none)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.presentAlert(title: "Error", message: "Failed to retrieve publishers: \(error.message)")
                    }
                }
            }
            
            // Obtains the authors related to book and display them on the tableView, it presents an error if happened.
            authorsQuery.find { [weak self] result in
                switch result {
                case .success(let authors):
                    self?.authors = authors
                    
                    // Update the UI
                    DispatchQueue.main.async {
                        self?.tableView.reloadSections(IndexSet([Section.author.rawValue]), with: .none)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.presentAlert(title: "Error", message: "Failed to retrieve authors: \(error.message)")
                    }
                }
            }
        } catch { // If there was an error during the creation of the queries, this block should catch it
            if let error = error as? ParseError {
                presentAlert(title: "Error", message: "Failed to retrieve authors: \(error.message)")
            } else {
                presentAlert(title: "Error", message: "Failed to retrieve authors: \(error.localizedDescription)")
            }
        }
    }
    
    private func setupTableView() {
        tableView.tableFooterView = .init()
        tableView.register(AuthorCell.self, forCellReuseIdentifier: AuthorCell.identifier)
        tableView.register(PublisherCell.self, forCellReuseIdentifier: PublisherCell.identifier)
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = .primary
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = .black
        navigationItem.title = book.title?.uppercased()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension BookDetailsController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count // Equals to 2. One sections is for authors and the other for publishers
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section.allCases[section] {
        case .author: return authors.count
        case .publisher: return publishers.count
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        Section.allCases[section].title
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section.allCases[indexPath.section] {
        case .author:
            let cell = tableView.dequeueReusableCell(withIdentifier: AuthorCell.identifier, for: indexPath) as! AuthorCell
            cell.model = authors[indexPath.row]
            return cell
        case .publisher:
            let cell = tableView.dequeueReusableCell(withIdentifier: PublisherCell.identifier, for: indexPath) as! PublisherCell
            cell.model = publishers[indexPath.row]
            return cell
        }
    }
}
