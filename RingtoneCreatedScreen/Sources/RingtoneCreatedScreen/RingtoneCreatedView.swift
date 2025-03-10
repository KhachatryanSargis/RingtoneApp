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

fileprivate enum RingtoneCreatedViewSection: Int {
    case empty
    case created
    case loading
}

fileprivate enum RingtoneCreatedViewItem: Hashable {
    case empty
    case createdAudio(RingtoneAudio)
    case loadingAudio(RingtoneAudio)
}

final class RingtoneCreatedView: NiblessView {
    // MARK: - Properties
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
    
    private var dataSource: UICollectionViewDiffableDataSource<RingtoneCreatedViewSection, RingtoneCreatedViewItem>!
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
        dataSource = makeDataSource()
        collectionView.dataSource = dataSource
        collectionView.delegate = self
    }
    
    private func setCollectionViewLayout() {
        collectionView.collectionViewLayout = makeLayout()
    }
    
    private func makeDataSource() -> UICollectionViewDiffableDataSource<RingtoneCreatedViewSection, RingtoneCreatedViewItem> {
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
        
        let loadingCellRegistration = UICollectionView.CellRegistration<RingtoneCreatedLoadingCell, RingtoneAudio> {
            cell, indexPath, audio in
            
            cell.setAudio(audio)
        }
        
        let emptyCellRegistration = UICollectionView.CellRegistration<RingtoneCreatedEmptyCell, RingtoneCreatedViewItem> {
            cell, indexPath, audio in
            
            cell.onImportButtonTapped = { [weak self] in
                guard let self = self else { return }
                
                self.viewModel.importRingtoneAudio()
            }
        }
        
        let dataSource =  UICollectionViewDiffableDataSource<RingtoneCreatedViewSection, RingtoneCreatedViewItem>(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            
            switch item {
            case .empty:
                return collectionView.dequeueConfiguredReusableCell(
                    using: emptyCellRegistration,
                    for: indexPath,
                    item: item
                )
            case .createdAudio(let audio):
                return collectionView.dequeueConfiguredReusableCell(
                    using: audioCellRegistration,
                    for: indexPath,
                    item: audio
                )
            case .loadingAudio(let audio):
                return collectionView.dequeueConfiguredReusableCell(
                    using: loadingCellRegistration,
                    for: indexPath,
                    item: audio
                )
            }
        }
        
        let loadingHeaderRegistration = UICollectionView.SupplementaryRegistration<RingtoneCreatedLoadingHeader>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { categoryHeader, elementKind, indexPath in }
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            return collectionView.dequeueConfiguredReusableSupplementary(
                using: loadingHeaderRegistration,
                for: indexPath
            )
        }
        
        return dataSource
    }
    
    private func makeLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            guard let self = self else { return .none }
            
            guard let favoritesViewSection = RingtoneCreatedViewSection(rawValue: sectionIndex)
            else { fatalError("unexpected created view section") }
            
            switch favoritesViewSection {
            case .empty:
                return self.createEmptySection()
            case .created:
                return self.createLoadedSection()
            case .loading:
                return self.createLoadingSection()
            }
        }
        
        return layout
    }
}

// MARK: - Layout Sections
extension RingtoneCreatedView {
    private func createEmptySection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(100)
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
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = .init(top: 0, leading: 0, bottom: 16, trailing: 0)
        
        return section
    }
    
    private func createLoadedSection() -> NSCollectionLayoutSection {
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
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = .init(top: 0, leading: 0, bottom: 16, trailing: 0)
        
        return section
    }
    
    private func createLoadingSection() -> NSCollectionLayoutSection {
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
                heightDimension: .estimated(50)
            ),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [header]
        section.interGroupSpacing = 8
        section.contentInsets = .init(top: 0, leading: 0, bottom: 16, trailing: 0)
        
        return section
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
        observeAudios()
    }
    
    private func observeAudios() {
        viewModel.$audios
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] audios in
                guard let self = self else { return }
                
                var snapshot = NSDiffableDataSourceSnapshot<RingtoneCreatedViewSection, RingtoneCreatedViewItem>()
                snapshot.appendSections([.empty, .created])
                
                if audios.isEmpty {
                    snapshot.appendItems([.empty], toSection: .empty)
                } else {
                    let createdAudios = audios.filter { $0.isLoading == false }
                    if !createdAudios.isEmpty {
                        snapshot.appendItems(createdAudios.map { .createdAudio($0) }, toSection: .created)
                    }
                    
                    let loadingAudios = audios.filter { $0.isLoading == true }
                    if !loadingAudios.isEmpty {
                        snapshot.appendSections([.loading])
                        snapshot.appendItems(loadingAudios.map { .loadingAudio($0) }, toSection: .loading)
                    }
                }
                
                self.dataSource.apply(snapshot, animatingDifferences: true)
            })
            .store(in: &cancellables)
    }
}
