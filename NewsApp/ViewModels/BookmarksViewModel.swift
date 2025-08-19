//
//  BookmarksViewModel.swift
//  NewsApp
//
//  Created by Yograj on 18/08/25.
//

import Foundation

/// A delegate protocol for `BookmarksViewModel` to notify the view layer about bookmark updates.
protocol BookmarksViewModelDelegate: AnyObject {
    /// Called when the list of bookmarked articles is updated.
    func bookmarksDidUpdate()
}

/// The ViewModel responsible for managing bookmarked articles.
/// Handles loading and removing bookmarks, while notifying the UI via `BookmarksViewModelDelegate`.
class BookmarksViewModel {
    
    /// Delegate to notify the UI layer whenever bookmarks are updated.
    weak var delegate: BookmarksViewModelDelegate?
    
    /// Service responsible for managing cached and bookmarked articles.
    private let cacheService: CacheManagerProtocol
    
    /// The list of currently bookmarked articles.
    private(set) var bookmarkedArticles: [Article] = []
    
    /// Initializes the view model with a cache service.
    /// - Parameter cacheService: Service conforming to `CacheManagerProtocol`. Defaults to a new `CacheManager`.
    init(cacheService: CacheManagerProtocol = CacheManager()) {
        self.cacheService = cacheService
    }
    
    /// Loads all bookmarked articles from the cache.
    /// Notifies the delegate after updating the `bookmarkedArticles` list.
    func loadBookmarks() {
        bookmarkedArticles = cacheService.getBookmarkedArticles()
        delegate?.bookmarksDidUpdate()
    }
    
    /// Removes a bookmark for the given article.
    /// After toggling the bookmark, it reloads the updated bookmark list.
    /// - Parameter article: The article to remove from bookmarks.
    func removeBookmark(for article: Article) {
        cacheService.toggleBookmark(for: article)
        loadBookmarks()
    }
}

