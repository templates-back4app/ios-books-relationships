//
//  DetailCell.swift
//  DSSBooks
//
//  Created by David on 24/03/22.
//

import UIKit

class DetailCell<Model>: UITableViewCell {
    class var identifier: String { "\(NSStringFromClass(Self.self)).identifier" }
    
    var model: Model? {
        didSet {
            guard let model = model else { return }
            setup(model: model)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setup(model: Model) {
        fatalError("You must override this method.")
    }
}
