//
//  ViewControllerExtension.swift
//  DSSBooks
//
//  Created by David on 12/03/22.
//

import UIKit.UIViewController

extension UIViewController {
    private func setupNavigationBar(title: String) {
        navigationController?.navigationBar.barTintColor = .primary
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = .black
        navigationItem.title = title.uppercased()
    }
    
    func presentAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Back", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func presentForm(
        title: String,
        description: String?,
        placeholder: String?,
        submitBlock: @escaping (String?) -> Void
    ) {
        let alertController = UIAlertController(title: title, message: description, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        let submitAction = UIAlertAction(title: "Submit", style: .default) { _ in
            let text = alertController.textFields?.first?.text
            submitBlock(text)
        }
        alertController.addAction(submitAction)
        
        alertController.addTextField { textField in
            textField.placeholder = placeholder
        }
        
        present(alertController, animated: true, completion: nil)
    }
}
