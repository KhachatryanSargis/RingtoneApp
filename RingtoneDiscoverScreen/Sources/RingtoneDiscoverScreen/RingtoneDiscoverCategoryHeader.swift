//
//  RingtoneDiscoverCategoryHeader.swift
//  RingtoneDiscoverScreen
//
//  Created by Sargis Khachatryan on 24.02.25.
//

import UIKit
import RingtoneUIKit
import RingtoneKit

final class RingtoneDiscoverCategoryHeader: NiblessCollectionReusableView {
    // MARK: - Properties
    private var categorySelectionResponder: RingtoneDiscoverCategorySelectionResponder?
    
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewLayout()
        )
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private lazy var dataSource = makeDataSource()
    
    // MARK: - Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        constructHierarchy()
        setCollectionViewDataSourceAndDelegate()
        setCollectionViewLayout()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setBlurEffect()
    }
    
    func setCategories(_ categories: [RingtoneCategory], responder: RingtoneDiscoverCategorySelectionResponder) {
        self.categorySelectionResponder = responder
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, RingtoneCategory>()
        snapshot.appendSections([0])
        snapshot.appendItems(categories, toSection: 0)
        
        dataSource.apply(snapshot, animatingDifferences: true) { [weak self] in
            guard let self = self else { return }
            
            self.preselectFirstCategory()
        }
    }
}

// MARK: - Style
extension RingtoneDiscoverCategoryHeader {
    private func setBackgroudColor() {
        backgroundColor = .theme.secondaryBackground
    }
    
    private func setBlurEffect() {
        if let existingBlurView = subviews.first(where: { $0 is UIVisualEffectView }) {
            existingBlurView.removeFromSuperview()
        }
        
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        
        blurView.frame = bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        insertSubview(blurView, at: 0)
    }
}

// MARK: - Hierarchy
extension RingtoneDiscoverCategoryHeader {
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
extension RingtoneDiscoverCategoryHeader {
    private func setCollectionViewDataSourceAndDelegate() {
        collectionView.dataSource = dataSource
        collectionView.delegate = self
    }
    
    private func setCollectionViewLayout() {
        collectionView.collectionViewLayout = makeLayout()
    }
    
    private func makeDataSource() -> UICollectionViewDiffableDataSource<Int, RingtoneCategory> {
        let categoryCellRegistration = UICollectionView.CellRegistration<RingtoneDiscoverCategoryCell, RingtoneCategory> {
            cell, indexPath, category in
            
            cell.category = category
        }
        
        let dataSource =  UICollectionViewDiffableDataSource<Int, RingtoneCategory>(
            collectionView: collectionView
        ) { collectionView, indexPath, category in
            collectionView.dequeueConfiguredReusableCell(
                using: categoryCellRegistration,
                for: indexPath,
                item: category
            )
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
                    heightDimension: .fractionalHeight(1)
                ),
                subitems: [item]
            )
            group.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            
            return section
        }
        
        return layout
    }
}

// MARK: - Selection
extension RingtoneDiscoverCategoryHeader: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let category = dataSource.itemIdentifier(for: indexPath)
        else { return false }
        
        guard collectionView.indexPathsForSelectedItems?.last != indexPath
        else { return true }
        
        return selectCategory(category)
    }
    
    private func selectCategory(_ category: RingtoneCategory) -> Bool {
        if let categorySelectionResponder = categorySelectionResponder {
            categorySelectionResponder.selectCategory(category)
            return true
        } else {
            return false
        }
    }
    
    private func preselectFirstCategory() {
        guard let categorySelectionResponder = categorySelectionResponder,
              let category = dataSource.itemIdentifier(for: .init(item: 0, section: 0)),
              collectionView.indexPathsForSelectedItems?.isEmpty == true
        else { return }
        
        categorySelectionResponder.selectCategory(category)
        
        collectionView.selectItem(
            at: IndexPath(item: 0, section: 0),
            animated: false,
            scrollPosition: []
        )
    }
}
