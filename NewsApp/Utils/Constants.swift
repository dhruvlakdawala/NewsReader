//
//  Constants.swift
//  NewsApp
//
//  Created by Yograj on 18/08/25.
//

import Foundation

/// A centralized place for storing app-wide constants.
/// Helps avoid hardcoding values throughout the codebase and makes maintenance easier.
struct Constants {
    
    /// Constants related to API configuration.
    struct API {
        /// Base URL for all News API requests.
        static let baseURL = "https://newsapi.org/v2"
        
        /// API key used to authenticate requests to NewsAPI.org.
        static let apiKey = "1d64a231a0e544bd9ab3473e84813b38"
    }
    
    /// Constants related to UI configuration.
    struct UI {
        /// Default system image name used when an article does not have a thumbnail.
        static let defaultImageName = "photo"
        
        /// SF Symbol name for a filled bookmark icon (used when an article is bookmarked).
        static let bookmarkImageFilled = "bookmark.fill"
        
        /// SF Symbol name for an empty bookmark icon (used when an article is not bookmarked).
        static let bookmarkImageEmpty = "bookmark"
    }
}
