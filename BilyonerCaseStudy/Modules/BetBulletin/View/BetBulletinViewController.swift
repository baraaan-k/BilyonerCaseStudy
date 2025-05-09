//
//  BetBulletinViewController.swift
//  BilyonerCaseStudy
//
//  Created by baran kutlu on 7.05.2025.
//


import UIKit
import RxSwift
import RxCocoa

final class BetBulletinViewController: UIViewController {
    
    private let viewModel: BetBulletinViewModel
    private let disposeBag = DisposeBag()
    
    private let tableView = UITableView()
    private var matches: [Match] = []
    private var popularMatches: [Match] = []
    
    private let searchBar = UISearchBar()
    private var isSearchVisible = false
    
    private let badgeLabel = UILabel()
    private let basketButton = UIButton(type: .custom)
    
    private let popularLabel: UILabel = {
        let label = UILabel()
        label.text = "Popular Matches"
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = UIColor(hex: "#58A85C")
        return label
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        layout.itemSize = CGSize(width: 236, height: 116)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .clear
        return cv
    }()
    
    private var tableViewTopWithSearch: NSLayoutConstraint!
    private var tableViewTopWithoutSearch: NSLayoutConstraint!
    private var popularLabelTopWithSearch: NSLayoutConstraint!
    private var popularLabelTopWithoutSearch: NSLayoutConstraint!
    
    init(viewModel: BetBulletinViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Bet Bulletin"
        
        setupViews()
        bindViewModel()
        viewModel.fetchMatches()
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
    }
    
    private func setupViews() {
        searchBar.placeholder = "Search team..."
        searchBar.isHidden = true
        searchBar.delegate = self
        
        basketButton.setImage(UIImage(systemName: "cart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)), for: .normal)
        basketButton.addTarget(self, action: #selector(goToBasket), for: .touchUpInside)
        basketButton.translatesAutoresizingMaskIntoConstraints = false
        
        badgeLabel.backgroundColor = .systemRed
        badgeLabel.textColor = .white
        badgeLabel.font = .systemFont(ofSize: 12, weight: .bold)
        badgeLabel.textAlignment = .center
        badgeLabel.layer.cornerRadius = 10
        badgeLabel.clipsToBounds = true
        badgeLabel.isHidden = true
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        basketButton.addSubview(badgeLabel)
        
        let searchButton = UIBarButtonItem(
            image: UIImage(systemName: "magnifyingglass"),
            style: .plain,
            target: self,
            action: #selector(toggleSearch)
        )
        
        let basketBarButton = UIBarButtonItem(customView: basketButton)
        navigationItem.rightBarButtonItems = [basketBarButton, searchButton]
        
        view.addSubview(searchBar)
        view.addSubview(popularLabel)
        view.addSubview(collectionView)
        view.addSubview(tableView)
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        popularLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableViewTopWithSearch = tableView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 8)
        tableViewTopWithoutSearch = tableView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 8)
        
        popularLabelTopWithSearch = popularLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16)
        popularLabelTopWithoutSearch = popularLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16)
        popularLabelTopWithoutSearch.isActive = true
        tableViewTopWithoutSearch.isActive = true
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            popularLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            popularLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            collectionView.topAnchor.constraint(equalTo: popularLabel.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 116),
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            basketButton.widthAnchor.constraint(equalToConstant: 32),
            basketButton.heightAnchor.constraint(equalToConstant: 32),
            badgeLabel.topAnchor.constraint(equalTo: basketButton.topAnchor, constant: -4),
            badgeLabel.trailingAnchor.constraint(equalTo: basketButton.trailingAnchor, constant: 4),
            badgeLabel.heightAnchor.constraint(equalToConstant: 18),
            badgeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 18)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MatchCell.self, forCellReuseIdentifier: MatchCell.identifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PopularMatchCell.self, forCellWithReuseIdentifier: PopularMatchCell.identifier)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func bindViewModel() {
        searchBar.rx.text.orEmpty
            .bind(to: viewModel.searchQuery)
            .disposed(by: disposeBag)
        
        viewModel.filteredMatches
            .asDriver()
            .drive(onNext: { [weak self] filtered in
                self?.matches = filtered
                self?.popularMatches = Array(filtered.prefix(5))
                self?.tableView.reloadData()
                self?.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        
        viewModel.selectedMatches
            .asDriver()
            .drive(onNext: { [weak self] selections in
                guard let self = self else { return }
                
                let count = selections.count
                self.badgeLabel.text = "\(count)"
                self.badgeLabel.isHidden = count == 0
                self.tableView.reloadData()
                
                let indexPathsToReload: [IndexPath] = self.popularMatches.enumerated()
                    .map { (index, match) in
                        IndexPath(item: index, section: 0)
                    }
                
                self.collectionView.reloadItems(at: indexPathsToReload)
            })
            .disposed(by: disposeBag)
        
        
    }
    
    @objc private func goToBasket() {
        if let nav = navigationController,
           let appCoordinator = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.appCoordinator {
            appCoordinator.showBasket(from: nav)
        }
    }
    
    @objc private func toggleSearch() {
        isSearchVisible.toggle()
        
        
        searchBar.isHidden = !isSearchVisible
        searchBar.showsCancelButton = isSearchVisible
        
        if isSearchVisible {
            tableViewTopWithoutSearch.isActive = false
            tableViewTopWithSearch.isActive = true
            
            popularLabelTopWithoutSearch.isActive = false
            popularLabelTopWithSearch.isActive = true
        } else {
            tableViewTopWithSearch.isActive = false
            tableViewTopWithoutSearch.isActive = true
            
            popularLabelTopWithSearch.isActive = false
            popularLabelTopWithoutSearch.isActive = true
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }, completion: { _ in
            if self.isSearchVisible {
                self.searchBar.becomeFirstResponder()
            } else {
                self.searchBar.resignFirstResponder()
                self.searchBar.text = ""
                self.viewModel.searchQuery.accept("")
            }
        })
    }
    
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}


extension BetBulletinViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 1 else { return nil }
        
        let label = UILabel()
        label.text = "Upcoming Matches"
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = UIColor(hex: "#58A85C")
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let container = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 36))
        container.backgroundColor = .systemBackground
        container.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 1 ? matches.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.section == 1,
              let cell = tableView.dequeueReusableCell(withIdentifier: MatchCell.identifier, for: indexPath) as? MatchCell else {
            return UITableViewCell()
        }
        let match = matches[indexPath.row]
        let selectedType = viewModel.selectedMatches.value.first(where: { $0.match.id == match.id })?.oddType
        cell.configure(with: match, selectedOddType: selectedType)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.section == 1 else { return }
        let selectedMatch = matches[indexPath.row]
        let basketVM = BetBasketViewModel(selectedMatches: viewModel.selectedMatches)
        let detailVC = MatchDetailViewController(match: selectedMatch, basketViewModel: basketVM)
        navigationController?.pushViewController(detailVC, animated: true)
        
    }
}


extension BetBulletinViewController: MatchCellDelegate {
    func didSelectOdd(match: Match, oddType: MatchOddType, value: Double) {
        viewModel.selectOdd(for: match, oddType: oddType, value: value)
    }
}


extension BetBulletinViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        toggleSearch()
        searchBar.text = ""
        viewModel.searchQuery.accept("")
    }
}


extension BetBulletinViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        popularMatches.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PopularMatchCell.identifier, for: indexPath) as? PopularMatchCell else {
            return UICollectionViewCell()
        }
        let match = popularMatches[indexPath.row]
        let selectedType = viewModel.selectedMatches.value.first(where: { $0.match.id == match.id })?.oddType
        cell.configure(with: match, selectedOddType: selectedType)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedMatch = matches[indexPath.row]
        let basketVM = BetBasketViewModel(selectedMatches: viewModel.selectedMatches)
        let detailVC = MatchDetailViewController(match: selectedMatch, basketViewModel: basketVM)
        navigationController?.pushViewController(detailVC, animated: true)
        
    }
}


extension BetBulletinViewController: PopularMatchCellDelegate {
    func didSelectPopularOdd(match: Match, oddType: MatchOddType, value: Double) {
        viewModel.selectOdd(for: match, oddType: oddType, value: value)
    }
}
