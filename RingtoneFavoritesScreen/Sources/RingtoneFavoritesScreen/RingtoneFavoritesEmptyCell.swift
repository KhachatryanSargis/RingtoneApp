//
//  RingtoneFavoritesEmptyCell.swift
//  RingtoneFavoritesScreen
//
//  Created by Sargis Khachatryan on 02.03.25.
//

import UIKit
import RingtoneUIKit

final class RingtoneFavoritesEmptyCell: NiblessCollectionViewCell {
    // MARK: - Properties
    var onImportButtonTapped: (() -> Void)?
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .theme.headline
        label.textColor = .theme.label
        label.text = "No Favorite Ringtones"
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .theme.headline
        label.textColor = .theme.secondaryLabel
        label.text = "You will see those here once you like some ringtones."
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .theme.liked
        return imageView
    }()
    
    // MARK: - Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        constructHierarchy()
    }
}

// MARK: - Style
extension RingtoneFavoritesEmptyCell {
    private func setBackgroundColor() {
        backgroundColor = .theme.background
    }
}

// MARK: - Hierarchy
extension RingtoneFavoritesEmptyCell {
    private func constructHierarchy() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
        stackView.addArrangedSubview(imageView)
        
        stackView.setCustomSpacing(16, after: descriptionLabel)
    }
}
