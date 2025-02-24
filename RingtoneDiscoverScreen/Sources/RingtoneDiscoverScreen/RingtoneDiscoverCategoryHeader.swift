//
//  RingtoneDiscoverCategoryHeader.swift
//  RingtoneDiscoverScreen
//
//  Created by Sargis Khachatryan on 24.02.25.
//

import UIKit
import RingtoneUIKit

class RingtoneDiscoverCategoryHeader: NiblessCollectionReusableView {
    // MARK: - Properties
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .theme.headline
        return label
    }()
    
    // MARK: - Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        constructHierarchy()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setBlurEffect()
    }
}

// MARK: - Style
extension RingtoneDiscoverCategoryHeader {
    private func setBlurEffect() {
        if let existingBlurView = subviews.first(where: { $0 is UIVisualEffectView }) {
            existingBlurView.removeFromSuperview()
        }
        
        let blurEffect = UIBlurEffect(style: .systemChromeMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        
        blurView.frame = bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        insertSubview(blurView, at: 0)
    }
}

// MARK: - Hierarchy
extension RingtoneDiscoverCategoryHeader {
    private func constructHierarchy() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -8),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
}
