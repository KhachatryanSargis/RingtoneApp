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
    private var audio: RingtoneAudio?
    private var responder: RingtoneDiscoverAudioCellActionsResponder?
    
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
        return button
    }()
    
    // MARK: - tile and description
    private let titleAndDescriptionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .top
        stackView.spacing = 4
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = .theme.headline
        label.textColor = .theme.label
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = .theme.subheadline
        label.textColor = .theme.secondaryLabel
        // TODO: Remove!
        label.text = "01:20 | 1.2 MB"
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
        return button
    }()
    
    private let useButton: UIButton = {
        var configuration = UIButton.Configuration.borderedTinted()
        configuration.imagePlacement = .top
        let button = UIButton(configuration: configuration)
        button.setImage(.theme.use, for: .normal)
        return button
    }()
    
    private let editButton: UIButton = {
        var configuration = UIButton.Configuration.borderedTinted()
        configuration.imagePlacement = .top
        let button = UIButton(configuration: configuration)
        button.setImage(.theme.edit, for: .normal)
        return button
    }()
    
    // MARK: - Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        setBackgroudColor()
        constructHierarchy()
        configureButtonTargets()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureLayer()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
}

// MARK: - Style
extension RingtoneDiscoverAudioCell {
    private func setBackgroudColor() {
        backgroundColor = .theme.secondaryBackground
    }
    
    private func configureLayer() {
        layer.cornerRadius = 8
    }
}

// MARK: - Hierarchy
extension RingtoneDiscoverAudioCell {
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
extension RingtoneDiscoverAudioCell {
    func setAudio(_ audio: RingtoneAudio, responder: RingtoneDiscoverAudioCellActionsResponder) {
        self.audio = audio
        self.responder = responder
        
        titleLabel.text = audio.title
        playPauseButton.setImage(audio.isPlaying ? .theme.pause : .theme.play, for: .normal)
        likeUnlikeButton.setImage(audio.isLiked ? .theme.liked : .theme.like, for: .normal)
    }
}

// MARK: - Button Actions
extension RingtoneDiscoverAudioCell {
    private func configureButtonTargets() {
        playPauseButton.addTarget(self, action: #selector(onPlayOrPause), for: .touchUpInside)
        likeUnlikeButton.addTarget(self, action: #selector(onLikeOrUnlike), for: .touchUpInside)
        useButton.addTarget(self, action: #selector(onUse), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(onEdit), for: .touchUpInside)
    }
    
    @objc
    private func onPlayOrPause() {
        guard let audio = audio else { return }
        print("onPlayOrPause")
    }
    
    @objc
    private func onLikeOrUnlike() {
        guard let responder = responder,
              let audio = audio
        else { return }
        
        responder.toggleAudioFavoriteStatus(audio)
    }
    
    @objc
    private func onUse() {
        guard let audio = audio else { return }
        print("onUse")
    }
    
    @objc
    private func onEdit() {
        guard let audio = audio else { return }
        print("onEdit")
    }
}

// MARK: - Cleanup
extension RingtoneDiscoverAudioCell {
    private func cleaup() {
        audio = nil
        responder = nil
    }
}
