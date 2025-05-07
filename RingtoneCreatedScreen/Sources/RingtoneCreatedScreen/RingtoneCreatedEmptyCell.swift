//
//  RingtoneCreatedEmptyCell.swift
//  RingtoneCreatedScreen
//
//  Created by Sargis Khachatryan on 26.02.25.
//

import UIKit
import RingtoneUIKit

final class RingtoneCreatedEmptyCell: NiblessCollectionViewCell {
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
        label.text = "You don't have created ringtones."
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .theme.headline
        label.textColor = .theme.secondaryLabel
        label.text = "Import a video or audio file to create your ringtone."
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let importButton: UIButton = {
        var configuration = UIButton.Configuration.borderedTinted()
        configuration.imagePlacement = .top
        configuration.image = .theme.import
        configuration.title = "Import"
        return UIButton(configuration: configuration)
    }()
    
    // MARK: - Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        constructHierarchy()
        setImportButtonTarget()
    }
}

// MARK: - Style
extension RingtoneCreatedEmptyCell {
    private func setBackgroundColor() {
        backgroundColor = .theme.background
    }
}

// MARK: - Hierarchy
extension RingtoneCreatedEmptyCell {
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
        stackView.addArrangedSubview(importButton)
        NSLayoutConstraint.activate([
            importButton.widthAnchor.constraint(equalTo: importButton.heightAnchor)
        ])
        
        stackView.setCustomSpacing(16, after: descriptionLabel)
    }
}

// MARK: - Import Button
extension RingtoneCreatedEmptyCell {
    private func setImportButtonTarget() {
        importButton.addTarget(
            self,
            action: #selector(importButtonTapped),
            for: .touchUpInside
        )
    }
    
    @objc private func importButtonTapped() {
        onImportButtonTapped?()
    }
}
