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
    case failed
}

fileprivate enum RingtoneCreatedViewItem: Hashable {
    case empty
    case createdAudio(RingtoneAudio)
    case failedAudio(RingtoneAudio)
}

final class RingtoneCreatedView: NiblessView {
    // MARK: - Properties
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewLayout()
        )
        collectionView.showsVerticalScrollIndicator = true
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
        
        let failedCellRegistration = UICollectionView.CellRegistration<RingtoneCreatedFailedCell, RingtoneAudio> {
            [weak self] cell, indexPath, audio in
            
            guard let self = self else { return }
            
            cell.setAudio(audio) { audio in
                self.viewModel.cleanFailedRingtoneAudio(audio)
            } onRetryButtonTapped: { audio in
                self.viewModel.retryFailedRingtoneAudio(audio)
            }
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
            case .failedAudio(let audio):
                return collectionView.dequeueConfiguredReusableCell(
                    using: failedCellRegistration,
                    for: indexPath,
                    item: audio
                )
            }
        }
        
        let failedHeaderRegistration = UICollectionView.SupplementaryRegistration<RingtoneCreatedFailedHeader>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { header, elementKind, indexPath in
            
            header.onClearButtonTapped = { [weak self] in
                guard let self = self else { return }
                
                self.viewModel.clearFailedRingtoneAudios()
            }
            
            header.onRetryButtonTapped = { [weak self] in
                guard let self = self else { return }
                
                self.viewModel.retryFailedRingtoneAudios()
            }
        }
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard let section = RingtoneCreatedViewSection(rawValue: indexPath.section)
            else { fatalError("unexpected created view section") }
            
            switch section {
            case .failed:
                return collectionView.dequeueConfiguredReusableSupplementary(
                    using: failedHeaderRegistration,
                    for: indexPath
                )
            default:
                return nil
            }
        }
        
        return dataSource
    }
    
    private func makeLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            guard let self = self else { return .none }
            
            guard let section = RingtoneCreatedViewSection(rawValue: sectionIndex)
            else { fatalError("unexpected created view section") }
            
            switch section {
            case .empty:
                return self.createEmptySection()
            case .created:
                return self.createLoadedSection()
            case .failed:
                return self.createFailedSection()
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
    
    private func createFailedSection() -> NSCollectionLayoutSection {
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
        
        if !dataSource.snapshot().itemIdentifiers(inSection: .failed).isEmpty {
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(50)
                ),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [header]
        }
        
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
                snapshot.appendSections([.empty, .created, .failed])
                
                if audios.isEmpty {
                    snapshot.appendItems([.empty], toSection: .empty)
                } else {
                    let createdAudios = audios.filter { $0.isFailed == false }
                    if !createdAudios.isEmpty {
                        snapshot.appendItems(createdAudios.map { .createdAudio($0) }, toSection: .created)
                    }
                    
                    let failedAudios = audios.filter { $0.isFailed == true }
                    if !failedAudios.isEmpty {
                        snapshot.appendItems(failedAudios.map { .failedAudio($0) }, toSection: .failed)
                    }
                }
                
                self.dataSource.apply(snapshot, animatingDifferences: true)
            })
            .store(in: &cancellables)
    }
}
