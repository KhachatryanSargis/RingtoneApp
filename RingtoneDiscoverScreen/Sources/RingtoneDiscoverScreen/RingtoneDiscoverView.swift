//
//  RingtoneDiscoverView.swift
//  RingtoneDiscoverScreen
//
//  Created by Sargis Khachatryan on 23.02.25.
//

import UIKit
import Combine
import RingtoneUIKit
import RingtoneKit

fileprivate enum RingtoneDiscoverSection: Int {
    case genres
    
    var title: String {
        switch self {
        case .genres:
            return "Genres"
        }
    }
}

fileprivate enum RingtoneDiscoverItem: Hashable {
    case category(RingtoneCategory)
}

final class RingtoneDiscoverView: NiblessView {
    // MARK: - Properties
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewLayout()
        )
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .systemBackground
        return collectionView
    }()
    
    private lazy var dataSource = makeDataSource()
    private var categories: [RingtoneCategory] = []
    private var cancellables: Set<AnyCancellable> = []
    private let viewModel: RingtoneDiscoverViewModel
    
    // MARK: - Methods
    init(viewModel: RingtoneDiscoverViewModel) {
        self.viewModel = viewModel
        super.init()
        setBackgroundColor()
        constructHierarchy()
        setCollectionViewDataSource()
        setCollectionViewLayout()
        observeViewModel()
    }
}

// MARK: - Style
extension RingtoneDiscoverView {
    private func setBackgroundColor() {
        backgroundColor = .systemBackground
    }
}

// MARK: - Hierarchy
extension RingtoneDiscoverView {
    private func constructHierarchy() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leftAnchor.constraint(equalTo: leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: rightAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: - Collection View
extension RingtoneDiscoverView {
    private func setCollectionViewDataSource() {
        collectionView.dataSource = dataSource
    }
    
    private func setCollectionViewLayout() {
        collectionView.collectionViewLayout = makeLayout()
    }
    
    private func makeDataSource() -> UICollectionViewDiffableDataSource<RingtoneDiscoverSection, RingtoneDiscoverItem> {
        let categoryCellRegistration = UICollectionView.CellRegistration<RingtoneDiscoverCategoryCell, RingtoneCategory> {
            cell, indexPath, category in
            
            cell.category = category
        }
        
        let dataSource =  UICollectionViewDiffableDataSource<RingtoneDiscoverSection, RingtoneDiscoverItem>(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            switch item {
            case .category(let category):
                collectionView.dequeueConfiguredReusableCell(
                    using: categoryCellRegistration,
                    for: indexPath,
                    item: category
                )
            }
        }
        
        let categoryHeaderRegistration = UICollectionView.SupplementaryRegistration<RingtoneDiscoverCategoryHeader>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) {
            supplementaryView, elementKind, indexPath in
            
            switch elementKind {
            case UICollectionView.elementKindSectionHeader:
                guard let section = RingtoneDiscoverSection(rawValue: indexPath.section) else {
                    fatalError("unexpected section in ringtone discover view")
                }
                
                supplementaryView.title = section.title
            default:
                return
            }
        }
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard let section = RingtoneDiscoverSection(rawValue: indexPath.section) else {
                fatalError("unexpected section in ringtone discover view")
            }
            
            switch section {
            case .genres:
                return collectionView.dequeueConfiguredReusableSupplementary(
                    using: categoryHeaderRegistration,
                    for: indexPath
                )
            }
        }
        
        return dataSource
    }
    
    private func makeLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment in
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)
                )
            )
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.3),
                    heightDimension: .fractionalWidth(0.3)
                ),
                subitems: [item]
            )
            group.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
            
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(44)
                ),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            header.pinToVisibleBounds = true
            
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = [header]
            section.orthogonalScrollingBehavior = .continuous
            
            return section
        }
        
        return layout
    }
}

// MARK: - View Model
extension RingtoneDiscoverView {
    private func observeViewModel() {
        viewModel.$categories
            .sink { [weak self] categories in
                guard let self = self else { return }
                
                self.categories = categories
                
                var snapshot = NSDiffableDataSourceSnapshot<RingtoneDiscoverSection, RingtoneDiscoverItem>()
                snapshot.appendSections([.genres])
                
                let categoryItems = categories.map { RingtoneDiscoverItem.category($0) }
                snapshot.appendItems(categoryItems, toSection: .genres)
                
                self.dataSource.apply(snapshot, animatingDifferences: true)
                
            }
            .store(in: &cancellables)
    }
}
