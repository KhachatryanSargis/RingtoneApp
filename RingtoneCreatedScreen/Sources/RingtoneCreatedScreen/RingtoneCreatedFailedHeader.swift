//
//  RingtoneCreatedFailedHeader.swift
//  RingtoneCreatedScreen
//
//  Created by Sargis Khachatryan on 10.03.25.
//

import UIKit
import RingtoneUIKit

final class RingtoneCreatedFailedHeader: NiblessCollectionReusableView {
    // MARK: - Properties
    var onClearButtonTapped: (() -> Void)?
    var onRetryButtonTapped: (() -> Void)?
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    private let clearAndRetryButtonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        return stackView
    }()
    
    private let clearButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        let button = UIButton(configuration: configuration)
        button.setImage(.theme.clear, for: .normal)
        return button
    }()
    
    private let retryButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        let button = UIButton(configuration: configuration)
        button.setImage(.theme.retry, for: .normal)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = .theme.headline
        label.textColor = .theme.label
        label.text = "Failed to Create Ringtones"
        return label
    }()
    
    // MARK: - Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        constructHierarchy()
        configureButtonTargets()
    }
}

// MARK: - Hierarchy
extension RingtoneCreatedFailedHeader {
    private func constructHierarchy() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
            stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -8),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
        
        titleLabel.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
        stackView.addArrangedSubview(titleLabel)
        
        stackView.addArrangedSubview(clearAndRetryButtonsStackView)
        
        clearAndRetryButtonsStackView.addArrangedSubview(clearButton)
        clearAndRetryButtonsStackView.addArrangedSubview(retryButton)
    }
}

// MARK: - Button Actions
extension RingtoneCreatedFailedHeader {
    private func configureButtonTargets() {
        clearButton.addTarget(self, action: #selector(onClear), for: .touchUpInside)
        retryButton.addTarget(self, action: #selector(onRetry), for: .touchUpInside)
    }
    
    @objc
    private func onClear() {
        onClearButtonTapped?()
    }
    
    @objc
    private func onRetry() {
        onRetryButtonTapped?()
    }
}
