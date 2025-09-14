//
//  ArticleCell.swift
//  NewsReader
//
//  Created by Sandeep on 14/09/25.
//

import UIKit

final class ArticleCell: UITableViewCell {
    static let reuseId = "ArticleCell"
    private let thumbImageView = UIImageView()
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let bookmarkButton = UIButton(type: .system)
    var bookmarkAction: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:)") }
    
    private func setupUI() {
        thumbImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbImageView.contentMode = .scaleAspectFill
        thumbImageView.clipsToBounds = true
        thumbImageView.layer.cornerRadius = 6
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 2
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        titleLabel.textColor = .label
        
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        authorLabel.textColor = .secondaryLabel
        
        bookmarkButton.translatesAutoresizingMaskIntoConstraints = false
        bookmarkButton.addTarget(self, action: #selector(didTapBookmark), for: .touchUpInside)
        
        contentView.addSubview(thumbImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(authorLabel)
        contentView.addSubview(bookmarkButton)
        
        NSLayoutConstraint.activate([
            thumbImageView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            thumbImageView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            thumbImageView.widthAnchor.constraint(equalToConstant: 110),
            thumbImageView.heightAnchor.constraint(equalToConstant: 70),
            thumbImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.bottomAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: thumbImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: bookmarkButton.leadingAnchor, constant: -8),
            titleLabel.topAnchor.constraint(equalTo: thumbImageView.topAnchor),
            
            authorLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            authorLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            authorLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.bottomAnchor),
            
            bookmarkButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            bookmarkButton.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            bookmarkButton.widthAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    @objc private func didTapBookmark() {
        bookmarkAction?()
    }
    
    func configure(with article: Article) {
        titleLabel.text = article.title
        authorLabel.text = article.author ?? article.source?.name ?? ""
        
        if let s = article.urlToImage, let url = URL(string: s) {
            ImageLoader.shared.loadImage(from: url) { [weak self] img in
                DispatchQueue.main.async { self?.thumbImageView.image = img ?? UIImage(systemName: "photo") }
            }
        } else {
            thumbImageView.image = UIImage(systemName: "photo")
        }
        
        let bookmarkImage = article.isBookmarked
        ? UIImage(systemName: "bookmark.fill")
        : UIImage(systemName: "bookmark")
        bookmarkButton.setImage(bookmarkImage, for: .normal)
        bookmarkButton.tintColor = .systemBlue
    }
}
