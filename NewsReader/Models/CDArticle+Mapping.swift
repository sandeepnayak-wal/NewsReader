//
//  CDArticle+Mapping.swift
//  NewsReader
//
//  Created by Sandeep on 14/09/25.
//

import Foundation
import CoreData

extension CDArticle {
    func update(with article: Article, context: NSManagedObjectContext) {
        self.url = article.url
        self.title = article.title
        self.author = article.author
        self.articleDescription = article.description
        self.urlToImage = article.urlToImage
        self.content = article.content
        self.publishedAt = article.publishedAt
        
        if self.isBookmarked == false {
            self.isBookmarked = article.isBookmarked
        }
    }

    func toArticle() -> Article {
        var art = Article(
            source: nil,
            author: self.author,
            title: self.title ?? "",
            description: self.articleDescription,
            url: self.url ?? "",
            urlToImage: self.urlToImage,
            publishedAt: self.publishedAt,
            content: self.content
        )
        art.isBookmarked = self.isBookmarked
        return art
    }
}
