//
//  CacheManager.swift
//  NewsApp
//
//  Created by Yograj on 18/08/25.
//

import Foundation

/// Protocol that defines caching operations for articles.
/// This allows flexibility so different caching strategies (e.g., Core Data, file system, UserDefaults)
/// can be implemented without changing the rest of the app.
protocol CacheManagerProtocol {
    
    /// Saves (caches) multiple articles locally.
    /// - Parameter articles: The list of articles to cache.
    func cacheArticles(_ articles: [Article])
    
    /// Retrieves cached articles from local storage.
    /// - Returns: A list of previously cached articles.
    func getCachedArticles() -> [Article]
    
    /// Toggles the bookmark status of a given article.
    /// - Parameter article: The article to bookmark or unbookmark.
    func toggleBookmark(for article: Article)
    
    /// Retrieves all bookmarked articles.
    /// - Returns: A list of articles marked as bookmarked by the user.
    func getBookmarkedArticles() -> [Article]
    
    /// Checks whether a given article is bookmarked.
    /// - Parameter article: The article to check.
    /// - Returns: `true` if bookmarked, otherwise `false`.
    func isBookmarked(_ article: Article) -> Bool
}

/// Manages caching of articles by delegating tasks to `CoreDataManager`.
/// Acts as an abstraction layer between the app and the underlying Core Data implementation.
class CacheManager: CacheManagerProtocol {
    
    /// Shared Core Data manager instance used for persistent storage.
    private let coreDataManager = CoreDataManager.shared
    
    /// Saves (caches) multiple articles using Core Data.
    /// - Parameter articles: The list of articles to cache.
    func cacheArticles(_ articles: [Article]) {
        coreDataManager.saveArticles(articles)
    }
    
    /// Retrieves cached articles from Core Data.
    /// - Returns: A list of previously cached articles.
    func getCachedArticles() -> [Article] {
        return coreDataManager.fetchCachedArticles()
    }
    
    /// Toggles the bookmark status of a given article in Core Data.
    /// - Parameter article: The article to bookmark/unbookmark.
    func toggleBookmark(for article: Article) {
        coreDataManager.toggleBookmark(for: article)
    }
    
    /// Fetches all bookmarked articles from Core Data.
    /// - Returns: A list of bookmarked articles.
    func getBookmarkedArticles() -> [Article] {
        return coreDataManager.fetchBookmarkedArticles()
    }
    
    /// Checks if a given article is bookmarked in Core Data.
    /// - Parameter article: The article to check.
    /// - Returns: `true` if the article is bookmarked, otherwise `false`.
    func isBookmarked(_ article: Article) -> Bool {
        return coreDataManager.isBookmarked(article)
    }
}
