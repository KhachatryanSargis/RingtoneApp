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
        label.text = "You don't have favorite ringtones."
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .theme.headline
        label.textColor = .theme.secondaryLabel
        label.text = "You will see them here once you start adding them."
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
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
            stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 4),
            stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -4),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
    }
}
