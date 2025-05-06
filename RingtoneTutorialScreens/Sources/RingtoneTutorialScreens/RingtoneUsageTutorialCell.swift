//
//  RingtoneUsageTutorialCell.swift
//  RingtoneTutorialScreens
//
//  Created by Sargis Khachatryan on 05.05.25.
//

import UIKit
import RingtoneUIKit
import RingtoneKit

final class RingtoneUsageTutorialCell: NiblessCollectionViewCell {
    // MARK: - Properties
    static let reuseID = "RingtoneUsageTutorialCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .theme.headline
        label.textColor = .theme.secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .theme.subheadline
        label.textColor = .theme.secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.backgroundColor = .theme.background.withAlphaComponent(0.5)
        return imageView
    }()
    
    // MARK: - Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        setBackgroundColor()
        constrcutHierarchy()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
        descriptionLabel.text = nil
        imageView.image = nil
    }
    
    func setStep(_ step: RingtoneUsageTutorialStep) {
        titleLabel.text = step.title
        descriptionLabel.text = step.description
        imageView.image = UIImage(named: step.imageName)
    }
}

// MARK: - Style
extension RingtoneUsageTutorialCell {
    private func setBackgroundColor() {
        backgroundColor = .clear
    }
}

// MARK: - Hierarchy
extension RingtoneUsageTutorialCell {
    private func constrcutHierarchy() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
        ])
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            descriptionLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
        ])
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
            imageView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            imageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }
}
