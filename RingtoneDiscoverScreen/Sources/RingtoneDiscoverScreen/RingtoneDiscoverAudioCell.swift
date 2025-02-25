//
//  RingtoneDiscoverAudioCell.swift
//  RingtoneDiscoverScreen
//
//  Created by Sargis Khachatryan on 25.02.25.
//

import UIKit
import RingtoneUIKit
import RingtoneKit

final class RingtoneDiscoverAudioCell: NiblessCollectionViewCell {
    // MARK: - Properties
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .top
        return stackView
    }()
    
    // MARK: - Title, Edit
    private let titleAndEditStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.spacing = 4
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = .theme.subheadline
        label.textColor = .theme.label
        return label
    }()
    
    private let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.setImage(.theme.edit, for: .normal)
        return button
    }()
    
    // MARK: - Like, Play, Duration
    private let likePlayDurationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .bottom
        stackView.spacing = 4
        return stackView
    }()
    
    private let likeUnlikeButton: UIButton = {
        let button = UIButton(type: .system)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.setImage(.theme.like, for: .normal)
        return button
    }()
    
    private let playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.setImage(.theme.play, for: .normal)
        return button
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .right
        label.font = .theme.subheadline
        label.textColor = .theme.secondaryLabel
        return label
    }()
    
    // MARK: - Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        setBackgroudColor()
        constructHierarchy()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureLayer()
    }
}

// MARK: - Style
extension RingtoneDiscoverAudioCell {
    private func setBackgroudColor() {
        backgroundColor = .theme.secondaryBackground
    }
    
    private func configureLayer() {
        layer.shadowColor = UIColor.theme.shadowColor.cgColor
        layer.shadowOffset = .init(width: 0, height: 1)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.2
        layer.cornerRadius = 4
    }
}

// MARK: - Hierarchy
extension RingtoneDiscoverAudioCell {
    private func constructHierarchy() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 4),
            stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -4),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])
        
        titleAndEditStackView.addArrangedSubview(titleLabel)
        titleAndEditStackView.addArrangedSubview(editButton)
        NSLayoutConstraint.activate([
            editButton.widthAnchor.constraint(equalToConstant: 40),
            editButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        likePlayDurationStackView.addArrangedSubview(likeUnlikeButton)
        NSLayoutConstraint.activate([
            likeUnlikeButton.widthAnchor.constraint(equalToConstant: 40),
            likeUnlikeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        likePlayDurationStackView.addArrangedSubview(playPauseButton)
        NSLayoutConstraint.activate([
            playPauseButton.widthAnchor.constraint(equalToConstant: 40),
            playPauseButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        likePlayDurationStackView.addArrangedSubview(durationLabel)
        
        stackView.addArrangedSubview(titleAndEditStackView)
        NSLayoutConstraint.activate([
            titleAndEditStackView.widthAnchor.constraint(equalTo: stackView.widthAnchor)
        ])
        stackView.addArrangedSubview(likePlayDurationStackView)
        NSLayoutConstraint.activate([
            likePlayDurationStackView.widthAnchor.constraint(equalTo: stackView.widthAnchor)
        ])
    }
}
