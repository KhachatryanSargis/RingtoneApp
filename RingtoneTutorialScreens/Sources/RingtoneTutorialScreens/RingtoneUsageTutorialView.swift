//
//  RingtoneUsageTutorialView.swift
//  RingtoneTutorialScreens
//
//  Created by Sargis Khachatryan on 05.05.25.
//

import UIKit
import RingtoneUIKit
import RingtoneKit

final class RingtoneUsageTutorialView: NiblessView {
    // MARK: - Properties
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        return collectionView
    }()
    
    private let viewModel: RingtoneUsageTutorialViewModel
    
    // MARK: - Methods
    init(viewModel: RingtoneUsageTutorialViewModel) {
        self.viewModel = viewModel
        super.init()
        constructHierarchy()
    }
}

// MARK: - Hierarchy
extension RingtoneUsageTutorialView {
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
