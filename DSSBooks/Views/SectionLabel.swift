//
//  SectionLabel.swift
//  DSSBooks
//
//  Created by David on 13/03/22.
//

import UIKit

class SectionLabel: UIView {
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .primary
        label.font = .boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var title: String? {
        get { label.text }
        set { label.text = newValue }
    }
    
    init(title: String) {
        super.init(frame: .zero)
        
        self.title = title
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupViews()
    }
    
    private func setupViews() {
        let lineView = UIView()
        lineView.backgroundColor = .lightGray
        lineView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(label)
        addSubview(lineView)
        
        label.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        label.topAnchor.constraint(equalTo: topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: lineView.topAnchor).isActive = true
        
        lineView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        lineView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive = true
        lineView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        lineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
}
