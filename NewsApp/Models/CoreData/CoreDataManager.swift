//
//  CoreDataManager.swift
//  NewsApp
//
//  Created by Yograj on 18/08/25.
//

import CoreData
import Foundation

import CoreData

/// A singleton class that manages all Core Data operations in the app.
/// This includes saving, fetching, and updating `Article` entities.
class CoreDataManager {
    
    /// Shared instance of `CoreDataManager` (Singleton pattern).
    /// Use this instead of creating multiple instances.
    static let shared = CoreDataManager()
    
    /// Private initializer to enforce singleton usage.
    private init() {}
    
    /// The persistent container that sets up and manages the Core Data stack.
    /// It loads the `NewsApp` data model.
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NewsApp")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data error: \(error)")
            }
        }
        return container
    }()
    
    /// The main context for Core Data operations.
    /// Used to save, fetch, and update data in the `persistentContainer`.
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    /// Saves the current state of the context if there are unsaved changes.
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Save error: \(error)")
            }
        }
    }
    
    // MARK: - Article Operations
    
    /// Saves multiple `Article` objects into Core Data.
    /// - Parameter articles: List of articles to save.
    func saveArticles(_ articles: [Article]) {
        articles.forEach { article in
            saveArticle(article)
        }
        saveContext()
    }
    
    /// Saves a single `Article` into Core Data if it does not already exist.
    /// - Parameter article: The article object to save.
    func saveArticle(_ article: Article) {
        let fetchRequest: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "url == %@", article.url)
        
        do {
            let existingArticles = try context.fetch(fetchRequest)
            
            // Only save if the article is not already stored
            if existingArticles.isEmpty {
                let articleEntity = ArticleEntity(context: context)
                articleEntity.title = article.title
                articleEntity.author = article.author
                articleEntity.urlToImage = article.urlToImage
                articleEntity.publishedAt = article.publishedAt
                articleEntity.content = article.content
                articleEntity.url = article.url
                articleEntity.sourceName = article.source.name
                articleEntity.isBookmarked = false
            }
        } catch {
            print("Fetch error: \(error.localizedDescription)")
        }
    }
    
    /// Fetches cached articles stored in Core Data.
    /// - Returns: An array of `Article` objects.
    func fetchCachedArticles() -> [Article] {
        let fetchRequest: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "publishedAt", ascending: false)]
        
        do {
            let articleEntities = try context.fetch(fetchRequest)
            
            // Convert `ArticleEntity` objects into `Article` models
            return articleEntities.compactMap { entity in
                guard let title = entity.title,
                      let url = entity.url,
                      let sourceName = entity.sourceName,
                      let publishedAt = entity.publishedAt else { return nil }
                
                return Article(
                    title: title,
                    author: entity.author,
                    urlToImage: entity.urlToImage,
                    publishedAt: publishedAt,
                    content: entity.content,
                    url: url,
                    source: Article.Source(name: sourceName)
                )
            }
        } catch {
            print("Fetch error: \(error)")
            return []
        }
    }
    
    /// Toggles the bookmark status of a given article.
    /// If the article is already bookmarked, it will be unbookmarked and vice versa.
    /// - Parameter article: The article whose bookmark status needs to be updated.
    func toggleBookmark(for article: Article) {
        let fetchRequest: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "url == %@", article.url)
        
        do {
            let articles = try context.fetch(fetchRequest)
            if let articleEntity = articles.first {
                articleEntity.isBookmarked.toggle()
                saveContext()
            }
        } catch {
            print("Toggle bookmark error: \(error.localizedDescription)")
        }
    }
    
    /// Fetches all bookmarked articles from Core Data.
    /// - Returns: An array of bookmarked `Article` objects.
    func fetchBookmarkedArticles() -> [Article] {
        let fetchRequest: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isBookmarked == YES")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "publishedAt", ascending: false)]
        
        do {
            let articleEntities = try context.fetch(fetchRequest)
            
            return articleEntities.compactMap { entity in
                guard let title = entity.title,
                      let url = entity.url,
                      let sourceName = entity.sourceName,
                      let publishedAt = entity.publishedAt else { return nil }
                
                return Article(
                    title: title,
                    author: entity.author,
                    urlToImage: entity.urlToImage,
                    publishedAt: publishedAt,
                    content: entity.content,
                    url: url,
                    source: Article.Source(name: sourceName)
                )
            }
        } catch {
            print("Fetch bookmarks error: \(error)")
            return []
        }
    }
    
    /// Checks if a given article is bookmarked.
    /// - Parameter article: The article to check.
    /// - Returns: `true` if the article is bookmarked, otherwise `false`.
    func isBookmarked(_ article: Article) -> Bool {
        let fetchRequest: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "url == %@ AND isBookmarked == YES", article.url)
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            return false
        }
    }
}

