//
//  RingtoneFadeSteppersView.swift
//  RingtoneUIKit
//
//  Created by Sargis Khachatryan on 27.04.25.
//

import UIKit
import Combine

public final class RingtoneFadeSteppersView: NiblessView {
    // MARK: - Properties
    @Published private(set) public var fadeInValue: TimeInterval = 0
    @Published private(set) public var fadeOutValue: TimeInterval = 0
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    private let fadeInStepper: RingtoneStepper = {
        let stepper = RingtoneStepper(
            alignment: .left,
            title: "Fade In"
        )
        return stepper
    }()
    
    private let fadeOutStepper: RingtoneStepper = {
        let stepper = RingtoneStepper(
            alignment: .right,
            title: "Fade Out"
        )
        return stepper
    }()
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Methods
    public override init() {
        super.init()
        constructHierarchy()
        observeStepperValues()
    }
    
    public func setFadeInValue(_ value: TimeInterval) {
        fadeInStepper.setValue(value)
    }
    
    public func setFadeOutValue(_ value: TimeInterval) {
        fadeOutStepper.setValue(value)
    }
    
    public func setMaximumValue(_ value: TimeInterval) {
        fadeInStepper.maximumValue = value
        fadeOutStepper.maximumValue = value
    }
}

// MARK: - Hierarchy
extension RingtoneFadeSteppersView {
    private func constructHierarchy() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: leftAnchor),
            stackView.rightAnchor.constraint(equalTo: rightAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        stackView.addArrangedSubview(fadeInStepper)
        stackView.addArrangedSubview(fadeOutStepper)
    }
}

// MARK: - Observe Stepper Values
extension RingtoneFadeSteppersView {
    private func observeStepperValues() {
        fadeInStepper.$value
            .sink { [weak self] value in
                guard let self = self else { return }
                
                self.fadeInValue = value
            }
            .store(in: &cancellables)
        
        fadeOutStepper.$value
            .sink { [weak self] value in
                guard let self = self else { return }
                
                self.fadeOutValue = value
            }
            .store(in: &cancellables)
    }
}
