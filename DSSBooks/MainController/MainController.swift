//
//  MainController.swift
//  DSSBooks
//
//  Created by David on 11/03/22.
//

import UIKit
import ParseSwift

extension UIColor {
    static let primary: UIColor = UIColor(red: 11 / 255, green: 140 / 255, blue: 229 / 255, alpha: 1)
}

extension UIButton {
    convenience init(title: String) {
        self.init(type: .system)
        setTitle(title, for: .normal)
        backgroundColor = .primary
        tintColor = .white
        layer.cornerRadius = 8
    }
}

class MainController: UIViewController {
    private var textFieldHeight: CGFloat { 44 }
    
    let bookTitleTextField: TextField = TextField(placeholder: "Title")
    
    let publishingYearTextField: TextField = {
        let textField = TextField(placeholder: "Publishing year")
        textField.keyboardType = .numberPad
        return textField
    }()
    
    let isbnTextField: TextField = TextField(placeholder: "ISBN")

    let publisherOptionsView: ListOptionsView = ListOptionsView(isMultiSelectionAllowed: true)
    
    var publishers: [Publisher] = [] {
        didSet {
            DispatchQueue.main.async {
                self.publisherOptionsView.options = self.publishers.compactMap(ListOptionsView.Option.init)
            }
        }
    }
    
    let genreOptionsView: ListOptionsView = ListOptionsView(isMultiSelectionAllowed: false)
    
    var genres: [Genre] = [] {
        didSet {
            DispatchQueue.main.async {
                self.genreOptionsView.options = self.genres.compactMap(ListOptionsView.Option.init)
            }
        }
    }
    
    let authorOptionsView: ListOptionsView = ListOptionsView(isMultiSelectionAllowed: true)
    
    var authors: [Author] = [] {
        didSet {
            DispatchQueue.main.async {
                self.authorOptionsView.options = self.authors.compactMap(ListOptionsView.Option.init)
            }
        }
    }
    
    private let addButton: UIButton = {
        let button = UIButton(title: "Add book")
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let listBooksButton: UIButton = {
        let button = UIButton(title: "List books")
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleHideKeyboard)))
        
        fetchGenres()
        fetchAuthors()
        fetchPublishers()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        
        let stackView = UIStackView(arrangedSubviews: [
            SectionLabel(title: "NEW BOOK"),
            bookTitleTextField,
            publishingYearTextField,
            isbnTextField
        ])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        let textFieldsHeight = CGFloat(stackView.arrangedSubviews.count) * (textFieldHeight + 8) - 8
        
        let publisherStackView = UIStackView(arrangedSubviews: [
            SectionLabel(title: "PUBLISHER"),
            publisherOptionsView
        ])
        publisherStackView.axis = .vertical
        publisherStackView.spacing = 8
        publisherStackView.distribution = .fillEqually
        publisherStackView.translatesAutoresizingMaskIntoConstraints = false
        let publisherHeight = CGFloat(publisherStackView.arrangedSubviews.count) * (textFieldHeight + 8) - 8

        let genreStackView = UIStackView(arrangedSubviews: [
            SectionLabel(title: "GENRE"),
            genreOptionsView
        ])
        genreStackView.axis = .vertical
        genreStackView.spacing = 8
        genreStackView.distribution = .fillEqually
        genreStackView.translatesAutoresizingMaskIntoConstraints = false
        let genreHeight = CGFloat(genreStackView.arrangedSubviews.count) * (textFieldHeight + 8) - 8
        
        let authorStackView = UIStackView(arrangedSubviews: [
            SectionLabel(title: "AUTHOR(S)"),
            authorOptionsView
        ])
        authorStackView.axis = .vertical
        authorStackView.spacing = 8
        authorStackView.distribution = .fillEqually
        authorStackView.translatesAutoresizingMaskIntoConstraints = false
        let authorHeight = CGFloat(authorStackView.arrangedSubviews.count) * (textFieldHeight + 8) - 8
        
        view.addSubview(stackView)
        view.addSubview(publisherStackView)
        view.addSubview(genreStackView)
        view.addSubview(authorStackView)
        view.addSubview(addButton)
        view.addSubview(listBooksButton)

        stackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -16).isActive = true
        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: textFieldsHeight).isActive = true
        
        publisherStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        publisherStackView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -16).isActive = true
        publisherStackView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 8).isActive = true
        publisherStackView.heightAnchor.constraint(equalToConstant: publisherHeight).isActive = true

        genreStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        genreStackView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -16).isActive = true
        genreStackView.topAnchor.constraint(equalTo: publisherStackView.bottomAnchor, constant: 8).isActive = true
        genreStackView.heightAnchor.constraint(equalToConstant: genreHeight).isActive = true
        
        authorStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        authorStackView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -16).isActive = true
        authorStackView.topAnchor.constraint(equalTo: genreStackView.bottomAnchor, constant: 8).isActive = true
        authorStackView.heightAnchor.constraint(equalToConstant: authorHeight).isActive = true
        
        addButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        addButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -16).isActive = true
        addButton.topAnchor.constraint(equalTo: authorStackView.bottomAnchor, constant: 8).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        listBooksButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        listBooksButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -16).isActive = true
        listBooksButton.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 8).isActive = true
        listBooksButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        addButton.addTarget(self, action: #selector(handleAddBook), for: .touchUpInside)
        listBooksButton.addTarget(self, action: #selector(handleShowBooks), for: .touchUpInside)
    }
    
    @objc private func handleAddBook() {
        saveBook()
    }
    
    @objc private func handleShowBooks() {
        let booksController = BooksController()
        navigationController?.pushViewController(booksController, animated: true)
    }
    
    private func setupNavigationBar() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAdd))
        addButton.tintColor = .white
        navigationItem.rightBarButtonItem = addButton
        navigationController?.navigationBar.barTintColor = .primary
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = .black
        navigationItem.title = "Relationships".uppercased()
    }
    
    @objc private func handleAdd() {
        let alertController = UIAlertController(title: "Add", message: nil, preferredStyle: .actionSheet)
        
        let addGenreAction = UIAlertAction(title: "Genre", style: .default) { [weak self] _ in
            self?.handleAddGenre()
        }
        
        let addPublisherAction = UIAlertAction(title: "Publisher", style: .default) { [weak self] _ in
            self?.handleAddPublisher()
        }
        
        let addAuthorAction = UIAlertAction(title: "Author", style: .default) { [weak self] _ in
            self?.handleAddAuthor()
        }
        
        alertController.addAction(addPublisherAction)
        alertController.addAction(addGenreAction)
        alertController.addAction(addAuthorAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func handleHideKeyboard() {
        view.endEditing(true)
    }
}
