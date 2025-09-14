//
//  ImageLoader.swift
//  NewsReader
//
//  Created by Sandeep on 14/09/25.
//

import UIKit

final class ImageLoader {
    static let shared = ImageLoader()
    private let cache = NSCache<NSURL, UIImage>()
    private init() {}
    
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        if let img = cache.object(forKey: url as NSURL) { completion(img); return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let d = data, let img = UIImage(data: d) else { completion(nil); return }
            self.cache.setObject(img, forKey: url as NSURL)
            completion(img)
        }.resume()
    }
}
