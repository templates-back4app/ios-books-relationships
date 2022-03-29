//
//  ListOptionsView.swift
//  DSSBooks
//
//  Created by David on 13/03/22.
//

import UIKit

fileprivate protocol OptionCellDelegate: class {
    func optionCell(_ optionCell: OptionCell, selectionStatusDidChange isSelected: Bool)
}

extension ListOptionsView.Option {
    init?(_ publisher: Publisher) {
        guard let id = publisher.objectId else { return nil }
        self.id = id
        title = publisher.name ?? "No publisher"
    }
    
    init?(_ genre: Genre) {
        guard let id = genre.objectId else { return nil }
        self.id = id
        title = genre.name ?? "No genre"
    }
    
    init?(_ author: Author) {
        guard let id = author.objectId else { return nil }
        self.id = id
        title = author.name ?? "No name"
    }
}

fileprivate class OptionCell: UICollectionViewCell {
    class var identifier: String { "\(NSStringFromClass(Self.self)).identifier" }
    
    static var cellHeight: CGFloat = 44
    static var titleFont: UIFont { UIFont.boldSystemFont(ofSize: 16) }
    
    weak var delegate: OptionCellDelegate?
    
    var isOptionSelected: Bool = false {
        didSet {
            titleLabel.textColor = isOptionSelected ? .white : .black
            titleLabel.backgroundColor = isOptionSelected ? .primary : .clear
        }
    }
    
    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = (Self.cellHeight - 16) / 2
        label.clipsToBounds = true
        label.textColor = .black
        label.font = Self.titleFont
        label.textAlignment = .center
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.primary.cgColor
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupViews()
    }
    
    private func setupViews() {
        contentView.addSubview(titleLabel)

        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
        
        titleLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelection)))
        titleLabel.isUserInteractionEnabled = true
    }
    
    @objc private func handleSelection() {
        isOptionSelected.toggle()
        delegate?.optionCell(self, selectionStatusDidChange: isOptionSelected)
    }
}

class ListOptionsView: UIControl {
    struct Option {
        let id: String
        let title: String
    }
    
    override var intrinsicContentSize: CGSize {
        .init(width: super.intrinsicContentSize.width, height: OptionCell.cellHeight)
    }
    
    var selectedOptionIds: Set<String> = []
    
    var options: [Option] = [] {
        didSet {
            DispatchQueue.main.async { self.optionsCollectionView.reloadData() }
        }
    }
    
    let isMultiSelectionAllowed: Bool
    
    private let optionsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    init(isMultiSelectionAllowed: Bool) {
        self.isMultiSelectionAllowed = isMultiSelectionAllowed
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        isMultiSelectionAllowed = false
        super.init(coder: coder)
        
        setupViews()
    }
    
    private func setupViews() {
        addSubview(optionsCollectionView)
        optionsCollectionView.backgroundColor = .clear
        
        optionsCollectionView.register(OptionCell.self, forCellWithReuseIdentifier: OptionCell.identifier)
        optionsCollectionView.delegate = self
        optionsCollectionView.dataSource = self
        
        optionsCollectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        optionsCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        optionsCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        optionsCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension ListOptionsView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        options.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OptionCell.identifier, for: indexPath) as! OptionCell
        cell.isOptionSelected = selectedOptionIds.contains(options[indexPath.item].id)
        cell.title = options[indexPath.item].title
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let title = options[indexPath.item].title
        let width = (title as NSString).size(withAttributes: [.font: OptionCell.titleFont]).width

        return CGSize(width: width + 32, height: OptionCell.cellHeight)
    }
}

// MARK: - OptionCellDelegate
extension ListOptionsView: OptionCellDelegate {
    fileprivate func optionCell(_ optionCell: OptionCell, selectionStatusDidChange isSelected: Bool) {
        guard let id = options.first(where: { $0.title == optionCell.title })?.id else { return }
        guard isMultiSelectionAllowed else {
            selectedOptionIds = [id]
            return DispatchQueue.main.async { self.optionsCollectionView.reloadData() }
        }
        
        if isSelected {
            selectedOptionIds.insert(id)
        } else {
            selectedOptionIds.remove(id)
        }
    }
}
