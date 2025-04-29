//
//  RingtoneFadeSlidersView.swift
//  RingtoneUIKit
//
//  Created by Sargis Khachatryan on 27.04.25.
//

import UIKit

public final class RingtoneFadeSlidersView: NiblessView {
    // MARK: - Properties
    @Published private(set) public var fadeInDuration: TimeInterval = 0
    @Published private(set) public var fadeOutDuration: TimeInterval = 0
    
    public var maximumValue: TimeInterval = 0.5 {
        didSet {
            reset(animated: true)
            
            fadeInSlider.maximumValue = Float(maximumValue)
            fadeOutSlider.maximumValue = Float(maximumValue)
        }
    }
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    // MARK: - Fade In
    private let fadeInStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    
    private let fadeInLabel: UILabel = {
        let label = UILabel()
        label.textColor = .theme.secondaryLabel
        label.font = .theme.headline.monospace()
        label.textAlignment = .left
        label.text = "Fade In | 0.0"
        return label
    }()
    
    private let fadeInSlider: RingtoneSlider = {
        let slider = RingtoneSlider(direction: .forward)
        slider.maximumValue = 5
        slider.minimumValue = 0
        return slider
    }()
    
    // MARK: - Fade Out
    private let fadeOutStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    
    private let fadeOutLabel: UILabel = {
        let label = UILabel()
        label.textColor = .theme.secondaryLabel
        label.font = .theme.headline.monospace()
        label.textAlignment = .right
        label.text = "0.0 | Fade Out"
        return label
    }()
    
    private let fadeOutSlider: RingtoneSlider = {
        let slider = RingtoneSlider(direction: .backward)
        slider.maximumValue = 5
        slider.minimumValue = 0
        return slider
    }()
    
    // MARK: - Methods
    public override init() {
        super.init()
        constructHierarchy()
        configureSliderTargets()
    }
    
    public func reset(animated: Bool = false) {
        if fadeInDuration > 0 {
            fadeInDuration = 0
            fadeInSlider.setValue(0, animated: animated)
            fadeInLabel.text = String(format: "Fade In | %.2f", 0)
        }
        
        if fadeOutDuration > 0 {
            fadeOutDuration = 0
            fadeOutSlider.setValue(0, animated: animated)
            fadeOutLabel.text = String(format: "%.2f | Fade Out", 0)
        }
    }
}

// MARK: - Hierarchy
extension RingtoneFadeSlidersView {
    private func constructHierarchy() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: leftAnchor),
            stackView.rightAnchor.constraint(equalTo: rightAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
        
        fadeInStackView.addArrangedSubview(fadeInLabel)
        fadeInStackView.addArrangedSubview(fadeInSlider)
        
        stackView.addArrangedSubview(fadeInStackView)
        
        fadeOutStackView.addArrangedSubview(fadeOutLabel)
        fadeOutStackView.addArrangedSubview(fadeOutSlider)
        
        stackView.addArrangedSubview(fadeOutStackView)
    }
}

// MARK: - Slider Targets
extension RingtoneFadeSlidersView {
    private func configureSliderTargets() {
        fadeInSlider.addTarget(self, action: #selector(onFadeInSliderValueChanged), for: .valueChanged)
        fadeOutSlider.addTarget(self, action: #selector(onFadeOutSliderValueChanged), for: .valueChanged)
    }
    
    @objc private func onFadeInSliderValueChanged(_ sender: UISlider) {
        fadeInDuration = TimeInterval(sender.value)
        fadeInLabel.text = String(format: "Fade In | %.2f", sender.value)
    }
    
    @objc private func onFadeOutSliderValueChanged(_ sender: UISlider) {
        fadeOutDuration = TimeInterval(sender.value)
        fadeOutLabel.text = String(format: "%.2f | Fade Out", sender.value)
    }
}
