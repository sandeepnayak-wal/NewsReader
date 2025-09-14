//
//  ArticlesListViewControllerViewController.swift
//  NewsReader
//
//  Created by Sandeep on 14/09/25.
//

import UIKit
import SafariServices

final class ArticlesListViewController: UIViewController {
    private let tableView = UITableView()
    private let vm = ArticlesListViewModel()
    private let searchController = UISearchController(searchResultsController: nil)
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Feed"
        view.backgroundColor = .systemBackground
        setupTable()
        setupBindings()
        vm.loadArticles()
    }
    
    private func setupTable() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ArticleCell.self, forCellReuseIdentifier: ArticleCell.reuseId)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        vm.onUpdate = { [weak self] in
            self?.refreshControl.endRefreshing()
            self?.tableView.reloadData()
        }
        vm.onError = { [weak self] err in
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
                let alert = UIAlertController(title: "Error", message: err.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
    }
    
    @objc private func didPullToRefresh() {
        vm.refresh()
    }
}

extension ArticlesListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.filteredArticles.count
    }
    func tableView(_ tv: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let art = vm.filteredArticles[indexPath.row]
        let cell = tv.dequeueReusableCell(withIdentifier: ArticleCell.reuseId, for: indexPath) as! ArticleCell
        cell.configure(with: art)
        cell.bookmarkAction = { [weak self] in
            guard let self = self else { return }
            self.vm.toggleBookmark(article: art)
            
            if let index = tv.indexPath(for: cell) {
                tv.reloadRows(at: [index], with: .none)
            }
        }
        
        
        return cell
    }
    func tableView(_ tv: UITableView, didSelectRowAt indexPath: IndexPath) {
        tv.deselectRow(at: indexPath, animated: true)
        let art = vm.filteredArticles[indexPath.row]
        if let url = URL(string: art.url) {
            let safari = SFSafariViewController(url: url)
            present(safari, animated: true)
        }
    }
}

extension ArticlesListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        vm.search(query: searchController.searchBar.text)
    }
}
