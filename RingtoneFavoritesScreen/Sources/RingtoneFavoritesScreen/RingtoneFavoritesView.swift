//
//  RingtoneFavoritesView.swift
//  RingtoneFavoritesScreen
//
//  Created by Sargis Khachatryan on 01.03.25.
//

import UIKit
import Combine
import RingtoneUIKit
import RingtoneKit

final class RingtoneFavoritesView: NiblessView {
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
    
    private lazy var dataSource = makeDataSource()
    private var cancellables: Set<AnyCancellable> = []
    private let viewModel: RingtoneFavoritesViewModel
    
    // MARK: - Methods
    init(viewModel: RingtoneFavoritesViewModel) {
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
extension RingtoneFavoritesView {
    private func setBackgroundColor() {
        backgroundColor = .theme.background
    }
}

// MARK: - Hierarchy
extension RingtoneFavoritesView {
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
extension RingtoneFavoritesView {
    private func setCollectionViewDataSourceAndDelegate() {
        collectionView.dataSource = dataSource
        collectionView.delegate = self
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
                favoriteResponder: self.viewModel,
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
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 8
            section.contentInsets = .init(top: 0, leading: 0, bottom: 16, trailing: 0)
            
            return section
        }
        
        return layout
    }
}

// MARK: - Collection View Delegate
extension RingtoneFavoritesView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        // TODO: Think of a usecase.
        return true
    }
}

// MARK: - View Model
extension RingtoneFavoritesView {
    private func observeViewModel() {
        observeAudios()
    }
    
    private func observeAudios() {
        viewModel.$audios
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                print(completion)
            }, receiveValue: { [weak self] audios in
                guard let self = self else { return }
                
                var snapshot = NSDiffableDataSourceSnapshot<Int, RingtoneAudio>()
                snapshot.appendSections([0])
                snapshot.appendItems(audios, toSection: 0)
                
                self.dataSource.apply(snapshot, animatingDifferences: true)
            })
            .store(in: &cancellables)
    }
}
