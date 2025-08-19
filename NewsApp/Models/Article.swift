//
//  Article.swift
//  NewsApp
//
//  Created by Yograj on 18/08/25.
//

import Foundation

/// Represents a single news article fetched from the API or stored in Core Data.
struct Article: Codable, Hashable {
    
    /// The title of the news article.
    let title: String
    
    /// The author of the article (may be `nil` if not provided by the source).
    let author: String?
    
    /// A URL string pointing to the article's image (thumbnail or cover).
    let urlToImage: String?
    
    /// The publication date and time of the article, as a string.
    /// (Often returned in ISO 8601 format, e.g., `"2025-08-19T12:00:00Z"`).
    let publishedAt: String
    
    /// The full article content (may be `nil` if only partial content is provided).
    let content: String?
    
    /// The direct link to the original article on the publisher's site.
    let url: String
    
    /// The source or publisher of the article (e.g., "BBC News").
    let source: Source
    
    /// Nested struct that represents the source of the article.
    struct Source: Codable, Hashable {
        /// The name of the publisher or news outlet.
        let name: String
    }
    
    // MARK: - Hashable & Equatable
    
    /// Provides a unique hash value for each article.
    /// Uses `url` since it's a unique identifier for an article.
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
    
    /// Compares two articles to determine if they are the same.
    /// Articles are considered equal if their `url` values match.
    static func == (lhs: Article, rhs: Article) -> Bool {
        return lhs.url == rhs.url
    }
}

/// Represents the entire response returned by the News API.
struct NewsResponse: Codable {
    
    /// The status of the API response (e.g., `"ok"` or `"error"`).
    let status: String
    
    /// The total number of results available for the given request.
    let totalResults: Int
    
    /// A list of articles returned in the response.
    let articles: [Article]
}
