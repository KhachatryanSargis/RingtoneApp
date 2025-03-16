//
//  RingtoneCreatedFailedCell.swift
//  RingtoneCreatedScreen
//
//  Created by Sargis Khachatryan on 10.03.25.
//

import UIKit
import RingtoneUIKit
import RingtoneKit

public final class RingtoneCreatedFailedCell: NiblessCollectionViewCell {
    // MARK: - Properties
    private var audio: RingtoneAudio?
    private var onClearButtonTapped: ((_ audio: RingtoneAudio) -> Void)?
    private var onRetryButtonTapped: ((_ audio: RingtoneAudio) -> Void)?
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
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
        label.numberOfLines = 2
        label.font = .theme.headline
        label.textColor = .theme.label
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = .theme.subheadline
        label.textColor = .theme.red
        return label
    }()
    
    // MARK: - clear and retry
    private let clearRetryStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        return stackView
    }()
    
    private let clearButton: UIButton = {
        var configuration = UIButton.Configuration.borderedTinted()
        configuration.imagePlacement = .top
        let button = UIButton(configuration: configuration)
        button.setImage(.theme.clear, for: .normal)
        return button
    }()
    
    private let retryButton: UIButton = {
        var configuration = UIButton.Configuration.borderedTinted()
        configuration.imagePlacement = .top
        let button = UIButton(configuration: configuration)
        button.setImage(.theme.retry, for: .normal)
        return button
    }()
    
    // MARK: - Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        setBackgroudColor()
        constructHierarchy()
        configureButtonTargets()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        configureLayer()
    }
}

// MARK: - RingtoneCreatedLoadingCell
extension RingtoneCreatedFailedCell {
    private func setBackgroudColor() {
        backgroundColor = .theme.secondaryBackground
    }
    
    private func configureLayer() {
        layer.cornerRadius = 4
    }
}

// MARK: - Hierarchy
extension RingtoneCreatedFailedCell {
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
        
        clearRetryStackView.addArrangedSubview(clearButton)
        NSLayoutConstraint.activate([
            clearButton.widthAnchor.constraint(equalTo: clearButton.heightAnchor)
        ])
        
        clearRetryStackView.addArrangedSubview(retryButton)
        NSLayoutConstraint.activate([
            retryButton.widthAnchor.constraint(equalTo: retryButton.heightAnchor)
        ])
        
        stackView.addArrangedSubview(titleAndDescriptionStackView)
        
        stackView.addArrangedSubview(clearRetryStackView)
    }
}

// MARK: - Set Audio
extension RingtoneCreatedFailedCell {
    public func setAudio(
        _ audio: RingtoneAudio,
        onClearButtonTapped: @escaping ((_ audio: RingtoneAudio) -> Void),
        onRetryButtonTapped: @escaping ((_ audio: RingtoneAudio) -> Void)
    ) {
        self.audio = audio
        self.onClearButtonTapped = onClearButtonTapped
        self.onRetryButtonTapped = onRetryButtonTapped
        
        titleLabel.text = audio.title
        descriptionLabel.text = audio.desciption
    }
}

// MARK: - Button Actions
extension RingtoneCreatedFailedCell {
    private func configureButtonTargets() {
        clearButton.addTarget(self, action: #selector(onClear), for: .touchUpInside)
        retryButton.addTarget(self, action: #selector(onRetry), for: .touchUpInside)
    }
    
    @objc
    private func onClear() {
        guard let audio = audio else { return }
        
        onClearButtonTapped?(audio)
    }
    
    @objc
    private func onRetry() {
        guard let audio = audio else { return }
        
        onRetryButtonTapped?(audio)
    }
}
