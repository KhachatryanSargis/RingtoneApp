//
//  RingtoneStepper.swift
//  RingtoneUIKit
//
//  Created by Sargis Khachatryan on 27.04.25.
//

import UIKit

final class RingtoneStepper: NiblessView {
    // MARK: - Properties
    @Published private(set) public var value: TimeInterval = 0
    
    var maximumValue: TimeInterval = 0.5 {
        didSet {
            setValue(stepper.minimumValue)
            
            stepper.maximumValue = maximumValue
        }
    }
    
    var minimumValue: TimeInterval = 0 {
        didSet {
            setValue(stepper.minimumValue)
            
            stepper.minimumValue = minimumValue
        }
    }
    
    var stepValue: TimeInterval = 0.1 {
        didSet {
            setValue(stepper.minimumValue)
            
            stepper.stepValue = stepValue
        }
    }
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .center
        return stackView
    }()
    
    private let stepper: UIStepper = {
        let stepper = UIStepper()
        stepper.setIncrementImage(.theme.plus, for: .normal)
        stepper.setDecrementImage(.theme.minus, for: .normal)
        return stepper
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.font = .theme.headline.monospace()
        label.textColor = .theme.secondaryLabel
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    private let alignment: RingtoneStepperAlignment
    private let title: String
    
    // MARK: - Methods
    init(alignment: RingtoneStepperAlignment, title: String) {
        self.alignment = alignment
        self.title = title
        super.init()
        
        constructHierarchy()
        configureStackView()
        configureStepper()
        configureTextLabel()
        updateTextLabel()
    }
    
    func setValue(_ value: TimeInterval) {
        guard stepper.value != value
        else { return }
        
        let clampedValue = min(max(value, minimumValue), maximumValue)
        
        stepper.value = clampedValue
        
        updateTextLabel()
    }
}

// MARK: - Hierarchy
extension RingtoneStepper {
    private func constructHierarchy() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: leftAnchor),
            stackView.rightAnchor.constraint(equalTo: rightAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        stackView.addArrangedSubview(stepper)
        stackView.addArrangedSubview(textLabel)
    }
}

// MARK: - Stack View
extension RingtoneStepper {
    private func configureStackView() {
        switch alignment {
        case .left:
            stackView.alignment = .leading
        case .right:
            stackView.alignment = .trailing
        }
    }
}

// MARK: - Stepper
extension RingtoneStepper {
    private func configureStepper() {
        stepper.maximumValue = maximumValue
        stepper.minimumValue = minimumValue
        stepper.stepValue = 0.1
        
        stepper.addTarget(self, action: #selector(onValueChanged), for: .valueChanged)
    }
    
    @objc private func onValueChanged(_ sender: UIStepper) {
        value = sender.value
        
        updateTextLabel()
    }
}

// MARK: - Text Label
extension RingtoneStepper {
    private func configureTextLabel() {
        switch alignment {
        case .left:
            textLabel.textAlignment = .left
        case .right:
            textLabel.textAlignment = .right
        }
    }
    
    private func updateTextLabel() {
        switch alignment {
        case .left:
            textLabel.text =  String(format: "\(title) | %.1f", stepper.value)
        case .right:
            textLabel.text =  String(format: "%.1f | \(title)", stepper.value)
        }
    }
}
