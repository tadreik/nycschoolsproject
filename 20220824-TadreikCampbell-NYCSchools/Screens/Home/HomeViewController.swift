//
//  ViewController.swift
//  20220824-TadreikCampbell-NYCSchools
//
//  Created by Tadreik Campbell on 8/24/22.
//

import UIKit
import Combine

class HomeViewController: UIViewController, UISearchControllerDelegate, UISearchResultsUpdating {
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.bounds.width, height: 150)
        layout.minimumInteritemSpacing = 10
        let v = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .systemGroupedBackground
        return v
    }()
    
    let search = UISearchController(searchResultsController: nil)
    
    let viewModel = HomeViewModel(dataFetcher: SchoolDataFetcher.shared)
    var observers: Set<AnyCancellable> = []
    
    var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupObservers()
    }
    
    private func setupViews() {
        navigationController?.navigationBar.prefersLargeTitles = true
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Type something here to search"
        navigationItem.searchController = search
        title = "NYC Schools"
        view.addSubviews(collectionView)
        collectionView.register(SchoolCollectionViewCell.self, forCellWithReuseIdentifier: SchoolCollectionViewCell.reuseID)
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    
    private func setupObservers() {
        viewModel.$visibleSchools
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &observers)
    }
    
}

// MARK: - Search
extension HomeViewController {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        viewModel.updateVisibleSchools(searchText: searchText)
    }
    
}

// MARK: - CollectionView Delegate
extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let school = viewModel.schools[safe: indexPath.item] {
            Navigator.showSchool(school)
        }
    }
    
    // infinite scrolling. Better user experience than using PrefetchDataSource
    // since we already have the entire dataset, this is commented out
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if indexPath.item >= viewModel.schools.count - 3 {
//            viewModel.fetchNextSchools()
//        }
    }
}

// MARK: - CollectionView Datasource
extension HomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.visibleSchools.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let schoolCell = collectionView.dequeueReusableCell(withReuseIdentifier: SchoolCollectionViewCell.reuseID, for: indexPath) as! SchoolCollectionViewCell
        if let school = viewModel.visibleSchools[safe: indexPath.item] {
            schoolCell.viewModel = SchoolCellViewModel(school: school)
        }
        return schoolCell
    }
    
}

