//
//  APIManager.swift
//  NewsApp
//
//  Created by Yograj on 18/08/25.
//

import Foundation
import Network

import Foundation
import Network

/// Protocol that defines the API operations for fetching news articles.
protocol APIManagerProtocol {
    
    /// Fetches top headlines from the News API.
    /// - Parameter completion: Closure returning either a list of articles or an error.
    func fetchTopHeadlines(completion: @escaping (Result<[Article], Error>) -> Void)
    
    /// Searches for articles based on a user query string.
    /// - Parameters:
    ///   - query: The search keyword entered by the user.
    ///   - completion: Closure returning either a list of matching articles or an error.
    func searchArticles(query: String, completion: @escaping (Result<[Article], Error>) -> Void)
}

/// A singleton class responsible for handling API requests to NewsAPI.org.
/// It manages network connectivity checks and performs article fetching and searching.
class APIManager: APIManagerProtocol {
    
    /// Shared instance of `APIManager` (Singleton).
    static let shared = APIManager()
    
    /// Base URL for NewsAPI endpoints.
    private let baseURL = "https://newsapi.org/v2"
    
    /// Your NewsAPI key.
    private let apiKey = "1d64a231a0e544bd9ab3473e84813b38"
    
    /// Shared `URLSession` for performing network requests.
    private let session = URLSession.shared
    
    /// Network path monitor used to check internet connectivity.
    private let monitor = NWPathMonitor()
    
    /// A background queue for monitoring network changes.
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    /// Indicates whether the device is currently connected to the internet.
    var isConnected = true
    
    /// Private initializer to enforce Singleton pattern.
    /// Starts monitoring the network when the class is initialized.
    private init() {
        startNetworkMonitoring()
    }
    
    /// Starts monitoring network connectivity.
    /// Updates `isConnected` whenever the network status changes.
    private func startNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
        }
        monitor.start(queue: queue)
    }
    
    // MARK: - API Methods
    
    /// Fetches the top news headlines from NewsAPI (defaults to U.S. headlines).
    /// - Parameter completion: Returns a list of `Article` objects or an error.
    func fetchTopHeadlines(completion: @escaping (Result<[Article], Error>) -> Void) {
        guard isConnected else {
            completion(.failure(NetworkError.noConnection))
            return
        }
        
        let urlString = "\(baseURL)/top-headlines?country=us&apiKey=\(apiKey)"
        performRequest(urlString: urlString, completion: completion)
    }
    
    /// Searches for news articles that match a given query string.
    /// - Parameters:
    ///   - query: The keyword or phrase to search for.
    ///   - completion: Returns a list of `Article` objects or an error.
    func searchArticles(query: String, completion: @escaping (Result<[Article], Error>) -> Void) {
        guard isConnected else {
            completion(.failure(NetworkError.noConnection))
            return
        }
        
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(baseURL)/everything?q=\(encodedQuery)&apiKey=\(apiKey)&sortBy=publishedAt"
        performRequest(urlString: urlString, completion: completion)
    }
    
    // MARK: - Helper Method
    
    /// Performs a network request and decodes the response into a `NewsResponse` model.
    /// - Parameters:
    ///   - urlString: The full URL string for the API request.
    ///   - completion: Returns either a list of `Article` objects or an error.
    private func performRequest(urlString: String, completion: @escaping (Result<[Article], Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        session.dataTask(with: url) { data, response, error in
            // Handle network or server error
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            // Ensure data is not nil
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.noData))
                }
                return
            }
            
            // Decode JSON response into `NewsResponse`
            do {
                let newsResponse = try JSONDecoder().decode(NewsResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(newsResponse.articles))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}

/// Custom error types used for networking issues.
enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case noConnection
    
    /// Provides user-friendly error descriptions.
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .noConnection:
            return "No internet connection"
        }
    }
}
