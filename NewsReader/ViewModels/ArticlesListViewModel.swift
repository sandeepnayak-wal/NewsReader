//
//  ArticlesListViewModel.swift
//  NewsReader
//
//  Created by Sandeep on 14/09/25.
//

import Foundation
import Network

final class ArticlesListViewModel {
    private let repo: ArticlesRepository
    private(set) var articles: [Article] = []
    private(set) var filteredArticles: [Article] = []
    
    var onUpdate: (() -> Void)?
    var onError: ((Error) -> Void)?
    private var monitor: NWPathMonitor?
    private var isConnected: Bool = true
    
    init(repository: ArticlesRepository = .shared) {
        self.repo = repository
        setupNetworkMonitor()
    }
    
    deinit {
        monitor?.cancel()
    }
    
    private func setupNetworkMonitor() {
        monitor = NWPathMonitor()
        monitor?.pathUpdateHandler = { [weak self] path in
            self?.isConnected = (path.status == .satisfied)
        }
        let q = DispatchQueue(label: "NetworkMonitor")
        monitor?.start(queue: q)
    }
    
    func loadArticles() {
        repo.fetchRemoteArticles { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let arts):
                    self?.articles = arts
                    self?.filteredArticles = arts
                    self?.onUpdate?()
                case .failure(let err):
                    // try cached
                    self?.repo.loadCachedArticlesAsync { cached in
                        self?.articles = cached
                        self?.filteredArticles = cached
                        DispatchQueue.main.async { self?.onUpdate?() }
                    }
                    self?.onError?(err)
                }
            }
        }
    }
    
    func refresh() {
        loadArticles()
    }
    
    func search(query: String?) {
        guard let q = query, !q.trimmingCharacters(in: .whitespaces).isEmpty else {
            filteredArticles = articles
            onUpdate?()
            return
        }
        filteredArticles = articles.filter { $0.title.localizedCaseInsensitiveContains(q) }
        onUpdate?()
    }
    
    func toggleBookmark(article: Article) {
        repo.toggleBookmark(articleURL: article.url) { [weak self] in
            if let idx = self?.articles.firstIndex(where: { $0.url == article.url }) {
                self?.articles[idx].isBookmarked.toggle()
            }
            if let idx2 = self?.filteredArticles.firstIndex(where: { $0.url == article.url }) {
                self?.filteredArticles[idx2].isBookmarked.toggle()
            }
            self?.onUpdate?()
        }
    }
    
    func getBookmarks(completion: @escaping ([Article]) -> Void) {
        repo.fetchBookmarksAsync { arts in
            completion(arts)
        }
    }
}
