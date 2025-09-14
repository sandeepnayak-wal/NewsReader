//
//  Article.swift
//  NewsReader
//
//  Created by Sandeep on 14/09/25.
//

import Foundation

struct NewsAPIResponse: Codable {
    let status: String
    let totalResults: Int?
    let articles: [Article]
}

struct Source: Codable, Equatable {
    let id: String?
    let name: String?
}

struct Article: Codable, Identifiable, Equatable {
    var id: String { url }
    let source: Source?
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: Date?
    let content: String?
    
    var isBookmarked: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case source, author, title, description, url, urlToImage, publishedAt, content
    }
}

