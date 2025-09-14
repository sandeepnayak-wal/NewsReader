//
//  CDArticle+CoreDataProperties.swift
//  NewsReader
//
//  Created by Sandeep on 14/09/25.
//
//

import Foundation
import CoreData


extension CDArticle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDArticle> {
        return NSFetchRequest<CDArticle>(entityName: "CDArticle")
    }

    @NSManaged public var url: String?
    @NSManaged public var title: String?
    @NSManaged public var author: String?
    @NSManaged public var articleDescription: String?
    @NSManaged public var urlToImage: String?
    @NSManaged public var publishedAt: Date?
    @NSManaged public var content: String?
    @NSManaged public var isBookmarked: Bool

}

extension CDArticle : Identifiable {

}
