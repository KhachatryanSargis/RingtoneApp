//
//  RingtoneSettingsView.swift
//  RingtoneSettingsScreen
//
//  Created by Sargis Khachatryan on 09.05.25.
//

import UIKit
import Combine
import RingtoneUIKit
import RingtoneKit

final class RingtoneSettingsView: NiblessView {
    // MARK: - Properties
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.register(
            RingtoneSettingsCell.self,
            forCellWithReuseIdentifier: RingtoneSettingsCell.reuseID
        )
        return collectionView
    }()
    
    private var actions: [RingtoneSettingsAction] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private let viewModel: RingtoneSettingsViewModel
    
    // MARK: - Methods
    init(viewModel: RingtoneSettingsViewModel) {
        self.viewModel = viewModel
        super.init()
        constructHierarchy()
        setCollectionViewDataSource()
        setTableViewDelegate()
        observeViewModel()
    }
}

// MARK: - Hierarchy
extension RingtoneSettingsView {
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

// MARK: - UICollectionViewDataSource
extension RingtoneSettingsView: UICollectionViewDataSource {
    private func setCollectionViewDataSource() {
        collectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return actions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: RingtoneSettingsCell.reuseID,
            for: indexPath
        ) as? RingtoneSettingsCell else {
            preconditionFailure("Unexpected cell type in RingtoneSettingsView")
        }
        
        let action = actions[indexPath.item]
        
        cell.setAction(action)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewFlowLayout
extension RingtoneSettingsView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private func setTableViewDelegate() {
        collectionView.delegate = self
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: collectionView.frame.width - 16, height: 50)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 8
    }
}

// MARK: - Observe View Model
extension RingtoneSettingsView {
    private func observeViewModel() {
        viewModel.$actions
            .sink { [weak self] actions in
                guard let self = self else { return }
                
                self.actions = actions
            }
            .store(in: &cancellables)
    }
}
