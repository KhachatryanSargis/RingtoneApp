//
//  RingtoneExportDeleteView.swift
//  RingtoneCreatedScreen
//
//  Created by Sargis Khachatryan on 16.03.25.
//

import UIKit
import RingtoneKit

public final class RingtoneExportDeleteView: NiblessView {
    // MARK: - Properties
    public var onExportButtonTapped: (() -> Void)?
    public var onDeleteButtonTapped: (() -> Void)?
    
    public var isEnabled: Bool = false {
        didSet {
            exportButton.isEnabled = isEnabled
            deleteButton.isEnabled = isEnabled
        }
    }
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        return stackView
    }()
    
    private let exportButton: UIButton = {
        var configuration = UIButton.Configuration.bordered()
        configuration.imagePlacement = .top
        let attributedTitle = AttributedString(
            "Export m4a",
            attributes: AttributeContainer([
                .font: UIFont.theme.headline.bold()
            ])
        )
        configuration.attributedTitle = attributedTitle
        return UIButton(configuration: configuration)
    }()
    
    private let deleteButton: UIButton = {
        var configuration = UIButton.Configuration.bordered()
        configuration.imagePlacement = .top
        let attributedTitle = AttributedString(
            "Delete",
            attributes: AttributeContainer([
                .font: UIFont.theme.headline.bold()
            ])
        )
        configuration.attributedTitle = attributedTitle
        return UIButton(configuration: configuration)
    }()
    
    private var blurView: UIVisualEffectView?
    
    // MARK: - Methods
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        constructHierarchy()
        configureButtonTargets()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        setBlurEffect()
    }
}

// MARK: - Style
extension RingtoneExportDeleteView {
    private func setBackgroudColor() {
        backgroundColor = .theme.secondaryBackground
    }
    
    private func setBlurEffect() {
        if blurView == nil {
            let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
            blurView = UIVisualEffectView(effect: blurEffect)
            
            guard let blurView = blurView else { return }
            
            blurView.frame = bounds
            blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            insertSubview(blurView, at: 0)
        }
        
        blurView?.frame = bounds
    }
}

// MARK: - Hierarchy
extension RingtoneExportDeleteView {
    private func constructHierarchy() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
            stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -8),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
        
        stackView.addArrangedSubview(exportButton)
        stackView.addArrangedSubview(deleteButton)
    }
}

// MARK: - Button Actions
extension RingtoneExportDeleteView {
    private func configureButtonTargets() {
        exportButton.addTarget(self, action: #selector(onExport), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(onDelete), for: .touchUpInside)
    }
    
    @objc
    private func onExport() {
        onExportButtonTapped?()
    }
    
    @objc
    private func onDelete() {
        onDeleteButtonTapped?()
    }
}
