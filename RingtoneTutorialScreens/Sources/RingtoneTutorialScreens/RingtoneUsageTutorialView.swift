//
//  RingtoneUsageTutorialView.swift
//  RingtoneTutorialScreens
//
//  Created by Sargis Khachatryan on 05.05.25.
//

import UIKit
import Combine
import RingtoneUIKit
import RingtoneKit

final class RingtoneUsageTutorialView: NiblessView {
    // MARK: - Properties
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.register(
            RingtoneUsageTutorialCell.self,
            forCellWithReuseIdentifier: RingtoneUsageTutorialCell.reuseID
        )
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.isUserInteractionEnabled = false
        return pageControl
    }()
    
    private var steps: [RingtoneUsageTutorialStep] = [] {
        didSet {
            collectionView.reloadData()
            pageControl.numberOfPages = steps.count
            pageControl.currentPage = 0
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private let viewModel: RingtoneUsageTutorialViewModel
    
    // MARK: - Methods
    init(viewModel: RingtoneUsageTutorialViewModel) {
        self.viewModel = viewModel
        super.init()
        setBackgroundColorAndView()
        constructHierarchy()
        setCollectionViewDelegate()
        setCollectionViewDataSource()
        observeViewModel()
    }
}

// MARK: - Style
extension RingtoneUsageTutorialView {
    private func setBackgroundColorAndView() {
        backgroundColor = .clear
        
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(visualEffectView)
        NSLayoutConstraint.activate([
            visualEffectView.leftAnchor.constraint(equalTo: leftAnchor),
            visualEffectView.rightAnchor.constraint(equalTo: rightAnchor),
            visualEffectView.topAnchor.constraint(equalTo: topAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: - Hierarchy
extension RingtoneUsageTutorialView {
    private func constructHierarchy() {
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        addSubview(pageControl)
        NSLayoutConstraint.activate([
            pageControl.leftAnchor.constraint(equalTo: leftAnchor),
            pageControl.rightAnchor.constraint(equalTo: rightAnchor),
            pageControl.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leftAnchor.constraint(equalTo: leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: rightAnchor),
            collectionView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: pageControl.topAnchor)
        ])
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension RingtoneUsageTutorialView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private func setCollectionViewDelegate() {
        collectionView.delegate = self
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let currentPage = Int((scrollView.contentOffset.x + (0.5 * pageWidth)) / pageWidth)
        pageControl.currentPage = currentPage
    }
}

// MARK: - UICollectionViewDataSource
extension RingtoneUsageTutorialView: UICollectionViewDataSource {
    private func setCollectionViewDataSource() {
        collectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return steps.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: RingtoneUsageTutorialCell.reuseID,
            for: indexPath
        ) as? RingtoneUsageTutorialCell else {
            preconditionFailure("Unexpected collection view cell type in RingtoneUsageTutorialView")
        }
        
        let step = steps[indexPath.item]
        
        cell.setStep(step)
        
        return cell
    }
}

// MARK: - View Model
extension RingtoneUsageTutorialView {
    private func observeViewModel() {
        viewModel.$steps
            .sink { [weak self] steps in
                guard let self = self else { return }
                
                self.steps = steps
            }
            .store(in: &cancellables)
    }
}
