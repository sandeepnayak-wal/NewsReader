//
//  ArticlesRepository.swift
//  NewsReader
//
//  Created by Sandeep on 14/09/25.
//

import Foundation
import CoreData

final class ArticlesRepository {
    static let shared = ArticlesRepository()
    private let api = NewsAPIService.shared
    private let context: NSManagedObjectContext
    
    private init(context: NSManagedObjectContext = PersistenceController.shared.viewContext) {
        self.context = context
    }
    
    // Fetch remote, persist in background, return articles or error
    func fetchRemoteArticles(completion: @escaping (Result<[Article], Error>) -> Void) {
        api.fetchArticles { result in
            switch result {
            case .success(let articles):
                print("Fetched")
                self.saveArticlesToCoreData(articles: articles) {
                    // return cached articles (ensures mapping uses saved bookmark flags)
                    self.loadCachedArticlesAsync { cached in
                        completion(.success(cached))
                    }
                }
            case .failure(let err):
                print("Not fetched")
                self.loadCachedArticlesAsync { cached in
                    completion(.failure(err))
                }
            }
        }
    }
    
    func fetchAll() -> [Article] {
        return loadCachedArticles()
    }
    
    // Save on background context to avoid UI blocking
    func saveArticlesToCoreData(articles: [Article], completion: (() -> Void)? = nil) {
        let bg = PersistenceController.shared.container.newBackgroundContext()
        bg.perform {
            for art in articles {
                let fetch: NSFetchRequest<CDArticle> = CDArticle.fetchRequest()
                fetch.predicate = NSPredicate(format: "url == %@", art.url)
                if let existing = (try? bg.fetch(fetch))?.first {
                    existing.update(with: art, context: bg)
                } else {
                    let cd = CDArticle(context: bg)
                    cd.update(with: art, context: bg)
                    cd.isBookmarked = false
                }
            }
            do { try bg.save() } catch { print("CoreData save error: \(error)") }
            DispatchQueue.main.async { completion?() }
        }
    }
    
    // Synchronous load - safe to call on background but we prefer async version
    func loadCachedArticles() -> [Article] {
        let req: NSFetchRequest<CDArticle> = CDArticle.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(key: "publishedAt", ascending: false)]
        do {
            let cdArticles = try context.fetch(req)
            return cdArticles.map { $0.toArticle() }
        } catch {
            print("Fetch cached error: \(error)")
            return []
        }
    }
    
    // Async version
    func loadCachedArticlesAsync(completion: @escaping ([Article]) -> Void) {
        context.perform {
            let req: NSFetchRequest<CDArticle> = CDArticle.fetchRequest()
            req.sortDescriptors = [NSSortDescriptor(key: "publishedAt", ascending: false)]
            let cds = (try? self.context.fetch(req)) ?? []
            completion(cds.map { $0.toArticle() })
        }
    }
    
    // Toggle bookmark safely
    func toggleBookmark(articleURL: String, completion: (() -> Void)? = nil) {
        context.perform {
            let fetch: NSFetchRequest<CDArticle> = CDArticle.fetchRequest()
            fetch.predicate = NSPredicate(format: "url == %@", articleURL)
            if let cd = (try? self.context.fetch(fetch))?.first {
                cd.isBookmarked.toggle()
                do { try self.context.save() } catch { print("Bookmark save error: \(error)") }
            } else {
            }
            DispatchQueue.main.async { completion?() }
        }
    }
    
    func fetchBookmarks() -> [Article] {
        let req: NSFetchRequest<CDArticle> = CDArticle.fetchRequest()
        req.predicate = NSPredicate(format: "isBookmarked == YES")
        req.sortDescriptors = [NSSortDescriptor(key: "publishedAt", ascending: false)]
        if let cds = try? context.fetch(req) {
            return cds.map { $0.toArticle() }
        }
        return []
    }
    
    func fetchBookmarksAsync(completion: @escaping ([Article]) -> Void) {
        context.perform {
            let req: NSFetchRequest<CDArticle> = CDArticle.fetchRequest()
            req.predicate = NSPredicate(format: "isBookmarked == YES")
            req.sortDescriptors = [NSSortDescriptor(key: "publishedAt", ascending: false)]
            let cds = (try? self.context.fetch(req)) ?? []
            completion(cds.map { $0.toArticle() })
        }
    }
}
