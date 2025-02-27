//
//  RingtoneCreatedView.swift
//  RingtoneCreatedScreen
//
//  Created by Sargis Khachatryan on 24.02.25.
//

import UIKit
import Combine
import RingtoneUIKit
import RingtoneKit

enum RingtoneCreatedViewAction {
    case `import`
}

fileprivate enum RingtoneCreatedViewItem {
    case addRingtone
    case ringtones
}

final class RingtoneCreatedView: NiblessView {
    // MARK: - Properties
    @Published private(set) var action: RingtoneCreatedViewAction?
    
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
    private var cancellables: Set<AnyCancellable> = []
    private let viewModel: RingtoneCreatedViewModel
    
    // MARK: - Methods
    init(viewModel: RingtoneCreatedViewModel) {
        self.viewModel = viewModel
        super.init()
        setBackgroundColor()
        constructHierarchy()
        setCollectionViewDataSourceAndDelegate()
        setCollectionViewLayout()
        observeViewModel()
    }
}

// MARK: - Style
extension RingtoneCreatedView {
    private func setBackgroundColor() {
        backgroundColor = .theme.background
    }
}

// MARK: - Hierarchy
extension RingtoneCreatedView {
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
extension RingtoneCreatedView {
    private func setCollectionViewDataSourceAndDelegate() {
        collectionView.dataSource = dataSource
        collectionView.delegate = self
    }
    
    private func setCollectionViewLayout() {
        collectionView.collectionViewLayout = makeLayout()
    }
    
    private func makeDataSource() -> UICollectionViewDiffableDataSource<Int, RingtoneCreatedViewItem> {
        let emptyCellRegistration = UICollectionView.CellRegistration<RingtoneCreatedEmptyCell, RingtoneCreatedViewItem>
        { (cell, indexPath, _) in
            cell.onImportButtonTapped = { [weak self] in
                guard let self = self else { return }
                self.action = .import
            }
        }
        
        let dataSource = UICollectionViewDiffableDataSource<Int, RingtoneCreatedViewItem>(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            switch item {
            case .addRingtone:
                return collectionView.dequeueConfiguredReusableCell(
                    using: emptyCellRegistration,
                    for: indexPath,
                    item: .addRingtone
                )
            case .ringtones:
                fatalError()
            }
        }
        
        return dataSource
    }
    
    private func makeLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment in
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(150)
                )
            )
            
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(150)
                ),
                subitems: [item]
            )
            group.contentInsets = .init(top: 0, leading: 8, bottom: 0, trailing: 8)
            group.interItemSpacing = .fixed(8)
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 8
            section.contentInsets = .init(top: 16, leading: 0, bottom: 16, trailing: 0)
            
            return section
        }
        
        return layout
    }
}

// MARK: - Collection View Delegate
extension RingtoneCreatedView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }
}

// MARK: - View Model
extension RingtoneCreatedView {
    private func observeViewModel() {
        viewModel.$items
            .sink { [weak self] items in
                guard let self = self else { return }
                
                var snapshot = NSDiffableDataSourceSnapshot<Int, RingtoneCreatedViewItem>()
                snapshot.appendSections([0])
                
                if items.isEmpty {
                    snapshot.appendItems([.addRingtone], toSection: 0)
                } else {
                    
                }
                
                self.dataSource.apply(snapshot, animatingDifferences: true)
            }
            .store(in: &cancellables)
    }
}
