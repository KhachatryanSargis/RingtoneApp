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

final class RingtoneDiscoverView: NiblessView {
    // MARK: - Properties
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewLayout()
        )
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.allowsSelection = false
        return collectionView
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, RingtoneAudio>!
    private var cancellables: Set<AnyCancellable> = []
    private let viewModel: RingtoneDiscoverViewModel
    
    // MARK: - Methods
    init(viewModel: RingtoneDiscoverViewModel) {
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
extension RingtoneDiscoverView {
    private func setBackgroundColor() {
        backgroundColor = .theme.background
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
    private func setCollectionViewDataSourceAndDelegate() {
        dataSource = makeDataSource()
        collectionView.dataSource = dataSource
//        collectionView.delegate = self
    }
    
    private func setCollectionViewLayout() {
        collectionView.collectionViewLayout = makeLayout()
    }
    
    private func makeDataSource() -> UICollectionViewDiffableDataSource<Int, RingtoneAudio> {
        let audioCellRegistration = UICollectionView.CellRegistration<RingtoneAudioCell, RingtoneAudio> {
            [weak self] cell, indexPath, audio in
            
            guard let self = self else { return }
            
            cell.setAudio(
                audio,
                playbackResponder: self.viewModel,
                favoriteResponder: self.viewModel.audioFavoriteStatusChangeResponder,
                editResponder: self.viewModel,
                exportResponder: self.viewModel
            )
        }
        
        let dataSource =  UICollectionViewDiffableDataSource<Int, RingtoneAudio>(
            collectionView: collectionView
        ) { collectionView, indexPath, audio in
            
            collectionView.dequeueConfiguredReusableCell(
                using: audioCellRegistration,
                for: indexPath,
                item: audio
            )
        }
        
        let categoryHeaderRegistration = UICollectionView.SupplementaryRegistration<RingtoneDiscoverCategoryHeader>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { [weak self] categoryHeader, elementKind, indexPath in
            
            guard let self = self else { return }
            
            categoryHeader.setCategories(
                viewModel.categories,
                responder: viewModel
            )
        }
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            return collectionView.dequeueConfiguredReusableSupplementary(
                using: categoryHeaderRegistration,
                for: indexPath
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
            
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(100)
                ),
                subitems: [item]
            )
            group.contentInsets = .init(top: 0, leading: 8, bottom: 0, trailing: 8)
            group.interItemSpacing = .fixed(8)
            
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalWidth(0.3)
                ),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            header.pinToVisibleBounds = true
            
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = [header]
            section.interGroupSpacing = 8
            section.contentInsets = .init(top: 16, leading: 0, bottom: 16, trailing: 0)
            
            return section
        }
        
        return layout
    }
}

// MARK: - Collection View Delegate
//extension RingtoneDiscoverView: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
//        // TODO: Think of a usecase.
//        return true
//    }
//}

// MARK: - View Model
extension RingtoneDiscoverView {
    private func observeViewModel() {
        observeCategories()
        observeAudios()
    }
    
    private func observeCategories() {
        viewModel.$categories
            .receive(on: DispatchQueue.main)
            .sink { [weak self] categories in
                guard let self = self else { return }
                
                var snapshot = NSDiffableDataSourceSnapshot<Int, RingtoneAudio>()
                snapshot.appendSections([0])
                
                self.dataSource.apply(snapshot, animatingDifferences: true)
                
            }
            .store(in: &cancellables)
    }
    
    private func observeAudios() {
        viewModel.$audios
            .receive(on: DispatchQueue.main)
            .sink { [weak self] audios in
                guard let self = self else { return }
                
                var snapshot = NSDiffableDataSourceSnapshot<Int, RingtoneAudio>()
                snapshot.appendSections([0])
                snapshot.appendItems(audios, toSection: 0)
                
                self.dataSource.apply(snapshot, animatingDifferences: true)
            }
            .store(in: &cancellables)
    }
}
