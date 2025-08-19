//
//  ArticlesVC.swift
//  NewsApp
//
//  Created by Yograj on 18/08/25.
//

import UIKit

/// A view controller responsible for displaying and managing a list of news articles.
/// Supports searching, bookmarking, refreshing, and theme toggling.
class ArticlesVC: UIViewController {
    
    /// The table view displaying articles.
    @IBOutlet weak var tableView: UITableView!
    
    /// The search bar for filtering and searching articles.
    @IBOutlet weak var searchBar: UISearchBar!
    
    /// The view model managing article data and bookmarks.
    private let viewModel = ArticlesViewModel()
    
    /// A refresh control for pull-to-refresh functionality.
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupViewModel()
        viewModel.loadArticles()
        updateEmptyState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /// Reloads table view to reflect updated bookmark states when coming back to this screen.
        tableView.reloadData()
    }
    
    // MARK: - Setup
    
    /// Configures UI elements such as table view, search bar, refresh control, and theme button.
    private func setupUI() {
        title = "News"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        
        // Setup pull-to-refresh
        refreshControl.addTarget(self, action: #selector(refreshTriggered), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        // Setup search bar
        searchBar.delegate = self
        searchBar.placeholder = "Search articles..."
        
        // Register reusable cell
        let nib = UINib(nibName: ArticleTableViewCell.identifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: ArticleTableViewCell.identifier)
        
        // Theme toggle button
        navigationItem.rightBarButtonItem = makeThemeBarButton()
    }
    
    /// Sets the view model delegate to this view controller.
    private func setupViewModel() {
        viewModel.delegate = self
    }
    
    // MARK: - Actions
    
    // Theme action handled by UIViewController extension: presentThemePickerAction()
    
    /// Triggered by pull-to-refresh gesture to reload articles.
    @objc private func refreshTriggered() {
        viewModel.refreshArticles()
    }
    
    /// Updates the empty state UI when no search results are found.
    private func updateEmptyState() {
        if !viewModel.searchText.isEmpty && viewModel.filteredArticles.isEmpty {
            let messageLabel = UILabel()
            messageLabel.text = "No articles are available."
            messageLabel.textColor = .secondaryLabel
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            messageLabel.translatesAutoresizingMaskIntoConstraints = false
            tableView.backgroundView = messageLabel
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
}

// MARK: - ArticlesViewModelDelegate
extension ArticlesVC: ArticlesViewModelDelegate {
    /// Called when articles are successfully updated in the view model.
    func articlesDidUpdate() {
        tableView.reloadData()
        refreshControl.endRefreshing()
        updateEmptyState()
    }
    
    /// Called when loading articles fails.
    /// - Parameter error: The error describing why the load failed.
    func articlesDidFailToLoad(error: Error) {
        refreshControl.endRefreshing()
        showError(error)
    }
    
    /// Called when the loading state changes (e.g., refreshing or fetching new articles).
    /// - Parameter isLoading: A Boolean indicating whether loading is in progress.
    func loadingStateDidChange(isLoading: Bool) {
        if !isLoading {
            refreshControl.endRefreshing()
        }
    }
    
    /// Displays an error message in an alert.
    /// - Parameter error: The error to display.
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ArticlesVC: UITableViewDataSource {
    /// Returns the number of rows (articles) in a given section.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredArticles.count
    }
    
    /// Configures and returns a cell for a given index path.
    /// Handles bookmark toggle action inside the cell.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ArticleTableViewCell.identifier,
            for: indexPath
        ) as? ArticleTableViewCell else {
            return UITableViewCell()
        }
        
        let article = viewModel.filteredArticles[indexPath.row]
        let isBookmarked = viewModel.isBookmarked(article)
        
        cell.configure(with: article, isBookmarked: isBookmarked)
        cell.onBookmarkTapped = { [weak self] article in
            self?.viewModel.toggleBookmark(for: article)
            self?.tableView.reloadRows(at: [indexPath], with: .none)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ArticlesVC: UITableViewDelegate {
    /// Handles row selection. Opens the selected article URL in Safari.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let article = viewModel.filteredArticles[indexPath.row]
        
        if let url = URL(string: article.url) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - UISearchBarDelegate
extension ArticlesVC: UISearchBarDelegate {
    /// Filters articles in real-time as the search text changes.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.filterArticles(with: searchText)
        updateEmptyState()
    }
    
    /// Called when the search button is tapped on the keyboard.
    /// Triggers a search request if the query is not empty.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        guard let query = searchBar.text, !query.isEmpty else { return }
        viewModel.searchArticles(with: query)
        updateEmptyState()
    }
    
    /// Clears the search bar text and resets the article list when cancel is tapped.
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        viewModel.filterArticles(with: "")
        updateEmptyState()
    }
}

