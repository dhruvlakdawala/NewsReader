//
//  ArticleEntity+CoreDataProperties.swift
//  NewsApp
//
//  Created by Yograj on 18/08/25.
//

import Foundation
import CoreData

extension ArticleEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ArticleEntity> {
        return NSFetchRequest<ArticleEntity>(entityName: "ArticleEntity")
    }

    @NSManaged public var title: String?
    @NSManaged public var author: String?
    @NSManaged public var urlToImage: String?
    @NSManaged public var publishedAt: String?
    @NSManaged public var content: String?
    @NSManaged public var url: String?
    @NSManaged public var sourceName: String?
    @NSManaged public var isBookmarked: Bool
}

extension ArticleEntity : Identifiable {
}
