//
//  TextField.swift
//  DSSBooks
//
//  Created by David on 13/03/22.
//

import UIKit

fileprivate class CustomTextField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool { false }
}

class TextField: UIControl {
    // MARK: - Properties
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: super.intrinsicContentSize.width, height: 50)
    }
    
    var customInputView: UIView? {
        get { textField.inputView }
        set { textField.inputView = newValue }
    }
    
    private var placeholderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    private var textField: UITextField = {
        let textField = CustomTextField()
        textField.textColor = .black
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.returnKeyType = .done
        return textField
    }()
    
    private var borderView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override var backgroundColor: UIColor? {
        didSet { placeholderLabel.backgroundColor = backgroundColor }
    }
    
    var text: String? {
        get { textField.text }
        set { textField.text = newValue }
    }
    
    var placeholder: String? {
        get { placeholderLabel.text }
        set { placeholderLabel.text = newValue }
    }
    
    var keyboardType: UIKeyboardType {
        get { textField.keyboardType }
        set { textField.keyboardType = newValue }
    }
    
    // MARK: - Init
    
    convenience init(placeholder: String) {
        self.init(frame: .zero)
        
        defer { self.placeholder = placeholder }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        
        defer { backgroundColor = .white }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    // MARK: - Handlers
    
    private func setupViews() {
        placeholderLabel.textColor = .gray
        borderView.layer.borderColor = placeholderLabel.textColor.cgColor
        
        addSubview(borderView)
        addSubview(placeholderLabel)
        addSubview(textField)
        
        let placeholderHeight = placeholderLabel.font.lineHeight
        
        placeholderLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14).isActive = true
        placeholderLabel.heightAnchor.constraint(equalToConstant: placeholderHeight).isActive = true
        
        textField.leadingAnchor.constraint(equalTo: placeholderLabel.leadingAnchor).isActive = true
        textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14).isActive = true
        textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive = true
        textField.topAnchor.constraint(equalTo: placeholderLabel.bottomAnchor, constant: 4).isActive = true
        
        borderView.topAnchor.constraint(equalTo: placeholderLabel.centerYAnchor).isActive = true
        borderView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        borderView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        borderView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        textField.addTarget(self, action: #selector(handleEditing), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(handleEndEditing), for: .editingDidEnd)
    }
    
    @objc private func handleEditing() {
        placeholderLabel.textColor = .primary
        borderView.layer.borderColor = UIColor.primary.cgColor
    }
    
    @objc private func handleEndEditing() {
        placeholderLabel.textColor = .gray
        borderView.layer.borderColor = UIColor.gray.cgColor
    }
}

