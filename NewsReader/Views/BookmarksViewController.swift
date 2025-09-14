//
//  BookmarksViewController.swift
//  NewsReader
//
//  Created by Sandeep on 14/09/25.
//

import UIKit
import SafariServices

final class BookmarksViewController: UIViewController {
    private let tableView = UITableView()
    private let vm = ArticlesListViewModel()
    private let searchController = UISearchController(searchResultsController: nil)
    private let refreshControl = UIRefreshControl()
    private var bookmarks: [Article] = []
    private var filteredBookmarks: [Article] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Bookmarks"
        view.backgroundColor = .systemBackground
        setupTable()
        setupSearch()
        loadBookmarks()
    }
    
    private func setupTable() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ArticleCell.self, forCellReuseIdentifier: ArticleCell.reuseId)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupSearch() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    @objc private func refreshData() {
        loadBookmarks()
        refreshControl.endRefreshing()
    }
    
    private func loadBookmarks() {
        ArticlesRepository.shared.fetchBookmarksAsync { [weak self] arts in
            DispatchQueue.main.async {
                self?.bookmarks = arts
                self?.filteredBookmarks = arts
                self?.tableView.reloadData()
            }
        }
    }
}

extension BookmarksViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredBookmarks.count
    }
    func tableView(_ tv: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let art = filteredBookmarks[indexPath.row]
        let cell = tv.dequeueReusableCell(withIdentifier: ArticleCell.reuseId, for: indexPath) as! ArticleCell
        cell.configure(with: art)
        cell.bookmarkAction = { [weak self] in
            ArticlesRepository.shared.toggleBookmark(articleURL: art.url) {
                self?.loadBookmarks()
            }
        }
        return cell
    }
    func tableView(_ tv: UITableView, didSelectRowAt indexPath: IndexPath) {
        tv.deselectRow(at: indexPath, animated: true)
        let art = filteredBookmarks[indexPath.row]
        if let url = URL(string: art.url) {
            let safari = SFSafariViewController(url: url)
            present(safari, animated: true)
        }
    }
}

extension BookmarksViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let q = searchController.searchBar.text, !q.trimmingCharacters(in: .whitespaces).isEmpty else {
            filteredBookmarks = bookmarks
            tableView.reloadData(); return
        }
        filteredBookmarks = bookmarks.filter { $0.title.localizedCaseInsensitiveContains(q) }
        tableView.reloadData()
    }
}
