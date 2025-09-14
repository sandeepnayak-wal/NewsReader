//
//  NewsAPIService.swift
//  NewsReader
//
//  Created by Sandeep on 14/09/25.
//

import Foundation

enum NetworkError: Error {
    case badURL, requestFailed(Error), invalidResponse, decodingError(Error), statusNotOK(String)
}

final class NewsAPIService {
    static let shared = NewsAPIService()
    private init() {}
    
    private let endpoint = "https://newsapi.org/v2/everything?q=apple&from=2025-09-13&to=2025-09-13&sortBy=popularity&apiKey=11478500c4ea4cc6af20d3e4ca703d9a"
    
    func fetchArticles(completion: @escaping (Result<[Article], NetworkError>) -> Void) {
        guard let url = URL(string: endpoint) else { completion(.failure(.badURL)); return }
        let req = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 25)
        let task = URLSession.shared.dataTask(with: req) { data, response, error in
            if let err = error { completion(.failure(.requestFailed(err))); return }
            guard let data = data else { completion(.failure(.invalidResponse)); return }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do {
                let resp = try decoder.decode(NewsAPIResponse.self, from: data)
                if resp.status.lowercased() == "ok" {
                    completion(.success(resp.articles))
                } else {
                    completion(.failure(.statusNotOK(resp.status)))
                }
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }
        task.resume()
    }
}
