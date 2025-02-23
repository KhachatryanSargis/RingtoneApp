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
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
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
    
    // MARK: - Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        constructHierarchy()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureLayer()
    }
}

// MARK: - Style
extension RingtoneDiscoverCategoryCell {
    private func configureLayer() {
        let shadowColor = UIColor { collection in
            switch collection.userInterfaceStyle {
            case .dark:
                return UIColor.white
            default:
                return UIColor.black
            }
        }.cgColor
        layer.shadowColor = shadowColor
        layer.shadowOffset = .init(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.2
        layer.cornerRadius = 4
    }
}

// MARK: - Hierarchy
extension RingtoneDiscoverCategoryCell {
    private func constructHierarchy() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 4),
            stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -4),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])
        
        stackView.addArrangedSubview(iconImageView)
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 50),
            iconImageView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        stackView.addArrangedSubview(nameLabel)
    }
}

// MARK: - Set Category
extension RingtoneDiscoverCategoryCell {
    private func setCategory(_ category: RingtoneCategory) {
        let color = UIColor { collection in
            switch collection.userInterfaceStyle {
            case .dark:
                return UIColor(hex: category.color.darkHex)
            default:
                return UIColor(hex: category.color.lightHex)
            }
        }
        backgroundColor = color
        nameLabel.text = category.displayName
        iconImageView.image = UIImage(systemName: "music.note")
    }
}
