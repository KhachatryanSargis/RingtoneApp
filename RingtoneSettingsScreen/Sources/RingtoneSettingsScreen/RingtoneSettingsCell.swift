//
//  RingtoneSettingsCell.swift
//  RingtoneSettingsScreen
//
//  Created by Sargis Khachatryan on 10.05.25.
//

import UIKit
import RingtoneUIKit
import RingtoneKit

final class RingtoneSettingsCell: NiblessCollectionViewCell {
    // MARK: - Properties
    static let reuseID = "RingtoneSettingsCell"
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .theme.headline
        label.textColor = .theme.label
        return label
    }()
    
    private let chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = .theme.rightChevron
        return imageView
    }()
    
    // MARK: - Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        setBackgroundColor()
        constructHierarchy()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setLayerCornerRadius()
    }
    
    func setAction(_ action: RingtoneSettingsAction) {
        switch action {
        case .changeTheme:
            imageView.image = .theme.changeTheme
            titleLabel.text = "Change Theme"
            chevronImageView.isHidden = true
        case .rateRingtoneKit:
            imageView.image = .theme.rateApp
            titleLabel.text = "Rate RingtoneKit"
            chevronImageView.isHidden = true
        case .sharRingtoneKit:
            imageView.image = .theme.shareApp
            titleLabel.text = "Share RingtoneKit"
            chevronImageView.isHidden = true
        case .showPrivacyPolicy:
            imageView.image = .theme.privacyPolicy
            titleLabel.text = "Privacy Policy"
            chevronImageView.isHidden = false
        case .showTermsOfService:
            imageView.image = .theme.termsOfService
            titleLabel.text = "Terms of Service"
            chevronImageView.isHidden = false
        case .contactSupport:
            imageView.image = .theme.contactSupport
            titleLabel.text = "Contact Support"
            chevronImageView.isHidden = true
        }
    }
}

// MARK: - Style
extension RingtoneSettingsCell {
    private func setBackgroundColor() {
        backgroundColor = .theme.secondaryBackground
    }
    
    private func setLayerCornerRadius() {
        layer.cornerRadius = 8
    }
}

// MARK: - Hierarchy
extension RingtoneSettingsCell {
    private func constructHierarchy() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
            stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -8),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
        
        stackView.addArrangedSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor)
        ])
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(chevronImageView)
        NSLayoutConstraint.activate([
            chevronImageView.widthAnchor.constraint(equalTo: chevronImageView.heightAnchor)
        ])
    }
}
