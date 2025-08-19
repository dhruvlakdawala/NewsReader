//
//  ArticlesViewModel.swift
//  NewsApp
//
//  Created by Yograj on 18/08/25.
//

import Foundation

/// A delegate protocol for `ArticlesViewModel` to notify the view layer about data and state changes.
protocol ArticlesViewModelDelegate: AnyObject {
    /// Called when articles are successfully updated.
    func articlesDidUpdate()
    
    /// Called when loading articles fails.
    func articlesDidFailToLoad(error: Error)
    
    /// Called whenever the loading state changes.
    func loadingStateDidChange(isLoading: Bool)
}

/// The ViewModel responsible for handling news articles fetching, caching, filtering, and bookmarks.
/// It communicates updates back to the UI using `ArticlesViewModelDelegate`.
class ArticlesViewModel {
    
    /// Delegate to notify the UI layer about updates, failures, or loading state changes.
    weak var delegate: ArticlesViewModelDelegate?
    
    /// Service responsible for making API requests.
    let networkService: APIManagerProtocol
    
    /// Service responsible for caching and bookmarking articles.
    let cacheService: CacheManagerProtocol
    
    /// All articles fetched from API or cache.
    var articles = [Article]()
    
    /// Articles filtered based on search text.
    var filteredArticles = [Article]()
    
    /// Boolean representing whether articles are currently being loaded.
    var isLoading = false
    
    /// Current search query text.
    var searchText = ""
    
    /// Initializes the view model with default or injected services.
    /// - Parameters:
    ///   - networkService: API service conforming to `APIManagerProtocol`. Defaults to `APIManager.shared`.
    ///   - cacheService: Cache service conforming to `CacheManagerProtocol`. Defaults to a new `CacheManager`.
    init(networkService: APIManagerProtocol = APIManager.shared,
         cacheService: CacheManagerProtocol = CacheManager()) {
        self.networkService = networkService
        self.cacheService = cacheService
    }
    
    /// Loads top headline articles from the API.
    /// Falls back to cached articles in case of an error.
    func loadArticles() {
        setLoading(true)
        
        networkService.fetchTopHeadlines { [weak self] result in
            guard let self = self else { return }
            
            self.setLoading(false)
            
            switch result {
            case .success(let articles):
                self.articles = articles
                self.cacheService.cacheArticles(articles)
                self.applySearchFilter()
                self.delegate?.articlesDidUpdate()
                
            case .failure(let error):
                // Load cached data on failure
                self.loadCachedArticles()
                self.delegate?.articlesDidFailToLoad(error: error)
            }
        }
    }
    
    /// Refreshes articles by re-fetching from the API.
    func refreshArticles() {
        loadArticles()
    }
    
    /// Searches for articles matching a given query string.
    /// - Parameter query: The search keyword.
    func searchArticles(with query: String) {
        searchText = query
        
        if query.isEmpty {
            applySearchFilter()
            return
        }
        
        setLoading(true)
        
        networkService.searchArticles(query: query) { [weak self] result in
            guard let self = self else { return }
            
            self.setLoading(false)
            
            switch result {
            case .success(let articles):
                self.articles = articles
                self.applySearchFilter()
                self.delegate?.articlesDidUpdate()
                
            case .failure(let error):
                self.delegate?.articlesDidFailToLoad(error: error)
            }
        }
    }
    
    /// Filters existing articles based on the given search text.
    /// - Parameter searchText: Text used for filtering articles by title.
    func filterArticles(with searchText: String) {
        self.searchText = searchText
        applySearchFilter()
        delegate?.articlesDidUpdate()
    }
    
    /// Toggles the bookmark state for a given article.
    /// - Parameter article: The article to bookmark/unbookmark.
    func toggleBookmark(for article: Article) {
        cacheService.toggleBookmark(for: article)
    }
    
    /// Checks if an article is bookmarked.
    /// - Parameter article: The article to check.
    /// - Returns: `true` if bookmarked, else `false`.
    func isBookmarked(_ article: Article) -> Bool {
        return cacheService.isBookmarked(article)
    }
    
    /// Loads cached articles from local storage and applies the current search filter.
    private func loadCachedArticles() {
        articles = cacheService.getCachedArticles()
        applySearchFilter()
        delegate?.articlesDidUpdate()
    }
    
    /// Applies the current search filter to articles.
    /// Updates `filteredArticles` based on `searchText`.
    private func applySearchFilter() {
        if searchText.isEmpty {
            filteredArticles = articles
        } else {
            filteredArticles = articles.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    /// Updates the loading state and notifies the delegate.
    /// - Parameter loading: A Boolean value indicating whether data is being loaded.
    private func setLoading(_ loading: Bool) {
        isLoading = loading
        delegate?.loadingStateDidChange(isLoading: loading)
    }
}

