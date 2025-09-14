//
//  ArticlesViewModel.swift
//  NewsReader
//
//  Created by Sandeep on 14/09/25.
//

import Foundation

class ArticlesViewModel {
    
    static let shared = ArticlesViewModel()
    
    private(set) var articles: [Article] = []
    private(set) var filteredArticles: [Article] = []
    
    private init() {}
    
    func refresh() {
        articles = ArticlesRepository.shared.fetchAll()
        filteredArticles = articles
    }
    
    func search(query: String) {
        guard !query.isEmpty else {
            filteredArticles = articles
            return
        }
        filteredArticles = articles.filter {
            $0.title.lowercased().contains(query.lowercased())
        }
    }
    
    func bookmarks() -> [Article] {
        return ArticlesRepository.shared.fetchBookmarks()
    }
    
    func reloadBookmarks() {
        articles = bookmarks()
        filteredArticles = articles
    }
}
