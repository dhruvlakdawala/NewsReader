//
//  Extensions.swift
//  NewsApp
//
//  Created by Yograj on 18/08/25.
//

import UIKit

// MARK: - UIViewController Extension
extension UIViewController {
    
    /// Displays a simple alert with a title, message, and an "OK" button.
    /// - Parameters:
    ///   - title: The title text shown in the alert.
    ///   - message: The message text shown in the alert.
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    /// Creates a standardized theme toggle bar button item that presents the theme picker.
    func makeThemeBarButton() -> UIBarButtonItem {
        return UIBarButtonItem(
            image: UIImage(systemName: "circle.lefthalf.filled"),
            style: .plain,
            target: self,
            action: #selector(presentThemePickerAction)
        )
    }
    
    /// Presents a reusable theme selection action sheet (System / Light / Dark).
    @objc func presentThemePickerAction() {
        let alert = UIAlertController(title: "Appearance", message: nil, preferredStyle: .actionSheet)
        let current = ThemeManager.shared.currentTheme
        
        let makeAction: (AppTheme) -> UIAlertAction = { theme in
            let checkmark = (theme == current) ? " ✓" : ""
            return UIAlertAction(title: theme.displayName + checkmark, style: .default) { _ in
                ThemeManager.shared.currentTheme = theme
            }
        }
        
        alert.addAction(makeAction(.system))
        alert.addAction(makeAction(.light))
        alert.addAction(makeAction(.dark))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }
        present(alert, animated: true)
    }
}

// MARK: - UIImageView Extension
extension UIImageView {
    
    /// Loads an image asynchronously from a given URL string.
    /// - Parameter urlString: The URL string of the image.
    ///
    /// If the URL is invalid or the image fails to load, a default system placeholder image (`"photo"`) is used.
    func loadImage(from urlString: String?) {
        guard let urlString = urlString,
              let url = URL(string: urlString) else {
            self.image = UIImage(systemName: "photo")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            
            // Ensure UI updates happen on the main thread
            DispatchQueue.main.async {
                self?.image = image
            }
        }.resume()
    }
}

// MARK: - UIView Extension
extension UIView {
    
    /// Adds a subview to the current view while disabling `translatesAutoresizingMaskIntoConstraints`.
    /// - Parameter subview: The subview to add.
    ///
    /// This makes it easier to use Auto Layout constraints programmatically,
    /// since the subview won’t rely on autoresizing masks.
    func addSubviewWithConstraints(_ subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
    }
}
