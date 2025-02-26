//
//  RingtoneDiscoverCategoryCell.swift
//  RingtoneDiscoverScreen
//
//  Created by Sargis Khachatryan on 23.02.25.
//

import UIKit
import RingtoneUIKit
import RingtoneKit

final class RingtoneDiscoverCategoryCell: NiblessCollectionViewCell {
    // MARK: - Properties
    var category: RingtoneCategory? {
        didSet {
            guard let category = category else { return }
            setCategory(category)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            UIViewPropertyAnimator(duration: 0.3, dampingRatio: 0.6) { [weak self] in
                guard let self = self else { return }
                self.selectionView.alpha = self.isSelected ? 1 : 0
                self.selectionView.isHidden = !self.isSelected
                self.layoutIfNeeded()
            }.startAnimation()
        }
    }
    
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        return stackView
    }()
    
    private let nameAndIconStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 4
        stackView.axis = .vertical
        stackView.alignment = .center
        return stackView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = .theme.headline
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private let selectionView: UIView = {
        let view = UIView()
        view.backgroundColor = .theme.accent
        view.isHidden = true
        return view
    }()
    
    // MARK: - Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        constructHierarchy()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureLayer()
        configureSelectionViewLayer()
    }
}

// MARK: - Style
extension RingtoneDiscoverCategoryCell {
    private func configureLayer() {
        layer.shadowColor = UIColor.theme.shadowColor.cgColor
        layer.shadowOffset = .init(width: 0, height: 0.5)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.2
        layer.cornerRadius = 8
    }
    
    private func configureSelectionViewLayer() {
        selectionView.layer.shadowColor = UIColor.black.cgColor
        selectionView.layer.shadowOffset = .init(width: 0, height: 0.5)
        selectionView.layer.shadowRadius = 4
        selectionView.layer.shadowOpacity = 0.2
        selectionView.layer.cornerRadius = 6
    }
}

// MARK: - Hierarchy
extension RingtoneDiscoverCategoryCell {
    private func constructHierarchy() {
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerStackView)
        NSLayoutConstraint.activate([
            containerStackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 4),
            containerStackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -4),
            containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
        ])
        
        containerStackView.addArrangedSubview(nameAndIconStackView)
        
        nameAndIconStackView.addArrangedSubview(iconImageView)
        NSLayoutConstraint.activate([
            iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor)
        ])
        
        nameAndIconStackView.addArrangedSubview(nameLabel)
        
        nameAndIconStackView.insertArrangedSubview(selectionView, at: 1)
        NSLayoutConstraint.activate([
            selectionView.widthAnchor.constraint(equalToConstant: 12),
            selectionView.heightAnchor.constraint(equalToConstant: 12)
        ])
    }
}

// MARK: - Set Category
extension RingtoneDiscoverCategoryCell {
    private func setCategory(_ category: RingtoneCategory) {
        nameLabel.text = category.displayName
        iconImageView.image = .theme.icon
        let color = UIColor(hex: category.color.lightHex)
        backgroundColor = color
        nameLabel.textColor = color.inverse
        iconImageView.tintColor = color.inverse
    }
}
