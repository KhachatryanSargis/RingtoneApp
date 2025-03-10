//
//  RingtoneCreatedLoadingCell.swift
//  RingtoneCreatedScreen
//
//  Created by Sargis Khachatryan on 10.03.25.
//

import UIKit
import RingtoneUIKit
import RingtoneKit

public final class RingtoneCreatedLoadingCell: NiblessCollectionViewCell {
    // MARK: - Properties
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()
    
    private let playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.setImage(.theme.play, for: .normal)
        button.isEnabled = false
        return button
    }()
    
    // MARK: - tile and description
    private let titleAndDescriptionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 4
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .theme.headline
        label.textColor = .theme.label
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .theme.subheadline
        label.textColor = .clear
        label.backgroundColor = .systemGray4
        label.text = "placeholder"
        return label
    }()
    
    // MARK: - like, use and edit
    private let likeUseEditStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        return stackView
    }()
    
    private let likeUnlikeButton: UIButton = {
        var configuration = UIButton.Configuration.borderedTinted()
        configuration.imagePlacement = .top
        let button = UIButton(configuration: configuration)
        button.setImage(.theme.like, for: .normal)
        button.isEnabled = false
        return button
    }()
    
    private let useButton: UIButton = {
        var configuration = UIButton.Configuration.borderedTinted()
        configuration.imagePlacement = .top
        let button = UIButton(configuration: configuration)
        button.setImage(.theme.use, for: .normal)
        button.isEnabled = false
        return button
    }()
    
    private let editButton: UIButton = {
        var configuration = UIButton.Configuration.borderedTinted()
        configuration.imagePlacement = .top
        let button = UIButton(configuration: configuration)
        button.setImage(.theme.edit, for: .normal)
        button.isEnabled = false
        return button
    }()
    
    // MARK: - Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        setBackgroudColor()
        constructHierarchy()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        configureLayer()
    }
}

// MARK: - RingtoneCreatedLoadingCell
extension RingtoneCreatedLoadingCell {
    private func setBackgroudColor() {
        backgroundColor = .theme.secondaryBackground
    }
    
    private func configureLayer() {
        layer.cornerRadius = 8
    }
}

// MARK: - Hierarchy
extension RingtoneCreatedLoadingCell {
    private func constructHierarchy() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8),
            stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        titleAndDescriptionStackView.addArrangedSubview(titleLabel)
        
        descriptionLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        titleAndDescriptionStackView.addArrangedSubview(descriptionLabel)
        NSLayoutConstraint.activate([
            descriptionLabel.widthAnchor.constraint(equalTo: titleAndDescriptionStackView.widthAnchor)
        ])
        
        likeUseEditStackView.addArrangedSubview(likeUnlikeButton)
        NSLayoutConstraint.activate([
            likeUnlikeButton.widthAnchor.constraint(equalTo: likeUnlikeButton.heightAnchor)
        ])
        
        likeUseEditStackView.addArrangedSubview(useButton)
        NSLayoutConstraint.activate([
            useButton.widthAnchor.constraint(equalTo: useButton.heightAnchor)
        ])
        
        likeUseEditStackView.addArrangedSubview(editButton)
        NSLayoutConstraint.activate([
            editButton.widthAnchor.constraint(equalTo: editButton.heightAnchor)
        ])
        
        stackView.addArrangedSubview(playPauseButton)
        NSLayoutConstraint.activate([
            playPauseButton.widthAnchor.constraint(equalToConstant: 40),
            playPauseButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        stackView.addArrangedSubview(titleAndDescriptionStackView)
        
        stackView.addArrangedSubview(likeUseEditStackView)
    }
}

// MARK: - Set Audio
extension RingtoneCreatedLoadingCell {
    public func setAudio(_ audio: RingtoneAudio) {
        titleLabel.text = audio.title
    }
}
