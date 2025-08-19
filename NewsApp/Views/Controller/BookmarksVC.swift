//
//  BookmarksVC.swift
//  NewsApp
//
//  Created by Yograj on 18/08/25.
//

import UIKit

/// A view controller responsible for displaying and managing bookmarked articles.
class BookmarksVC: UIViewController {
    
    /// Table view to display the list of bookmarked articles.
    @IBOutlet weak var tableView: UITableView!
    
    /// ViewModel that manages bookmark data and interactions.
    private let viewModel = BookmarksViewModel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()          // Configure UI elements (table view, navigation bar, etc.)
        setupViewModel()   // Bind ViewModel delegate
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadBookmarks()   // Refresh bookmarks whenever the view appears
        updateEmptyState()          // Show empty state if no bookmarks available
    }
    
    // MARK: - Setup
    
    /// Configures UI components, navigation bar, and table view.
    func setupUI() {
        title = "Bookmarks"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        
        // Register custom article cell
        let nib = UINib(nibName: ArticleTableViewCell.identifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: ArticleTableViewCell.identifier)
        
        // Add theme toggle button in navigation bar
        navigationItem.rightBarButtonItem = makeThemeBarButton()
    }
    
    /// Sets the ViewModel delegate for receiving updates.
    func setupViewModel() {
        viewModel.delegate = self
    }
    
    // MARK: - Empty State
    
    /// Updates the table view background with a message if no bookmarks exist.
    func updateEmptyState() {
        if viewModel.bookmarkedArticles.isEmpty {
            let messageLabel = UILabel()
            messageLabel.text = "No bookmarked articles are available."
            messageLabel.textColor = .secondaryLabel
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            messageLabel.translatesAutoresizingMaskIntoConstraints = false
            tableView.backgroundView = messageLabel
            
            // Center message in table view
            NSLayoutConstraint.activate([
                messageLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
                messageLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
                messageLabel.leadingAnchor.constraint(greaterThanOrEqualTo: tableView.leadingAnchor, constant: 16),
                messageLabel.trailingAnchor.constraint(lessThanOrEqualTo: tableView.trailingAnchor, constant: -16)
            ])
            
            tableView.separatorStyle = .none
        } else {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
        }
    }

    // MARK: - Theme Handling
    
    // Theme action handled by UIViewController extension: presentThemePickerAction()
}

// MARK: - BookmarksViewModelDelegate
extension BookmarksVC: BookmarksViewModelDelegate {
    /// Reloads table view and updates empty state when bookmarks are updated.
    func bookmarksDidUpdate() {
        tableView.reloadData()
        updateEmptyState()
    }
}

// MARK: - UITableViewDataSource
extension BookmarksVC: UITableViewDataSource {
    /// Returns the number of bookmarked articles.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.bookmarkedArticles.count
    }
    
    /// Configures and returns a cell for each bookmarked article.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ArticleTableViewCell.identifier,
            for: indexPath
        ) as? ArticleTableViewCell else {
            return UITableViewCell()
        }
        
        let article = viewModel.bookmarkedArticles[indexPath.row]
        
        // Configure article cell
        cell.configure(with: article, isBookmarked: true)
        
        // Handle bookmark toggle action
        cell.onBookmarkTapped = { [weak self] article in
            self?.viewModel.removeBookmark(for: article)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension BookmarksVC: UITableViewDelegate {
    /// Handles article selection → opens article URL in Safari.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let article = viewModel.bookmarkedArticles[indexPath.row]
        
        if let url = URL(string: article.url) {
            UIApplication.shared.open(url)
        }
    }
    
    /// Handles swipe-to-delete action for removing bookmarks.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let article = viewModel.bookmarkedArticles[indexPath.row]
            viewModel.removeBookmark(for: article)
        }
    }
}
