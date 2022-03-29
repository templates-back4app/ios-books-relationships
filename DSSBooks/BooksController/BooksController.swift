//
//  BooksController.swift
//  DSSBooks
//
//  Created by David on 23/03/22.
//

import UIKit
import ParseSwift

class BookCell: DetailCell<Book> {
    override func setup(model: Book) {
        guard let title = model.title, let year = model.publishingYear else { return }
        textLabel?.text = [title, "\(year)"].joined(separator: ", ")
        
        if let isbn = model.isbn?.value {
            detailTextLabel?.text = "ISBN: \(isbn)"
        }
    }
}

class BooksController: UITableViewController {
    private var books: [Book] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchBooks()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = .primary
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = .black
        navigationItem.title = "Books".uppercased()
    }
        
    private func fetchBooks() {
        guard books.isEmpty else { return }
                
        let query = Book.query().include("isbn", "genre")
        
        query.find { [weak self] result in
            switch result {
            case .success(let books):
                self?.books = books
                DispatchQueue.main.async {
                    self?.tableView.reloadSections(IndexSet([0]), with: .right)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.presentAlert(title: "Error", message: "Failed to retrieve books: \(error.message)")
                }
            }
        }
    }
    
    private func setupTableView() {
//        queryInputView.frame.size.height = 44 + 2 * 8
//
//        queryInputView.options = [.init(id: "0", title: "test1"), .init(id: "1", title: "test2")]
//
//        tableView.tableHeaderView = queryInputView
        tableView.tableFooterView = .init()
        tableView.register(BookCell.self, forCellReuseIdentifier: BookCell.identifier)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension BooksController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        books.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BookCell.identifier, for: indexPath) as! BookCell
        cell.model = books[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailsController = BookDetailsController(book: books[indexPath.row])
        navigationController?.pushViewController(detailsController, animated: true)
    }
}
