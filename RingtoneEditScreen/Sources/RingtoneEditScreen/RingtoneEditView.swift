//
//  RingtoneEditView.swift
//  RingtoneEditScreen
//
//  Created by Sargis Khachatryan on 08.04.25.
//

import UIKit
import Combine
import RingtoneUIKit
import RingtoneKit

final class RingtoneEditView: NiblessView {
    private enum ActiveEdgeView {
        case left(xPosition: CGFloat)
        case right(xPosition: CGFloat)
    }
    
    // MARK: - Properties
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 32
        return stackView
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .clear
        textField.textColor = .theme.label
        return textField
    }()
    
    private let waveformView: RingtoneWaveformView = {
        let waveFormView = RingtoneWaveformView()
        return waveFormView
    }()
    
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .theme.accent.withAlphaComponent(0.5)
        return view
    }()
    
    // MARK: - Handles
    private let leftEdgeView: UIView = {
        let view = UIView()
        view.backgroundColor = .theme.red
        return view
    }()
    
    private var leftEdgeViewConstraint: NSLayoutConstraint? {
        didSet {
            oldValue?.isActive = false
            leftEdgeViewConstraint?.isActive = true
        }
    }
    
    private let rightEdgeView: UIView = {
        let view = UIView()
        view.backgroundColor = .theme.red
        return view
    }()
    
    private var rightEdgeViewConstraint: NSLayoutConstraint? {
        didSet {
            oldValue?.isActive = false
            rightEdgeViewConstraint?.isActive = true
        }
    }
    
    // MARK: - Time Lables
    private let leftTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .theme.headline
        label.textColor = .theme.secondaryLabel
        label.textAlignment = .left
        return label
    }()
    
    private let rightTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .theme.headline
        label.textColor = .theme.secondaryLabel
        label.textAlignment = .right
        return label
    }()
    
    // MARK: - Controls
    private let controlsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
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
    
    private let saveButton: UIButton = {
        var configuration = UIButton.Configuration.borderedProminent()
        configuration.baseForegroundColor = .theme.background
        configuration.title = "Save"
        let button = UIButton(configuration: configuration)
        return button
    }()
    
    private let cancelButton: UIButton = {
        var configuration = UIButton.Configuration.borderedProminent()
        configuration.baseForegroundColor = .theme.background
        configuration.title = "Cancel"
        let button = UIButton(configuration: configuration)
        return button
    }()
    
    private let zoomInButton: UIButton = {
        var configuration = UIButton.Configuration.tinted()
        configuration.image = .theme.zoomIn
        let button = UIButton(configuration: configuration)
        return button
    }()
    
    private let zoomOutButton: UIButton = {
        var configuration = UIButton.Configuration.tinted()
        configuration.image = .theme.zoomOut
        let button = UIButton(configuration: configuration)
        return button
    }()
    
    // MARK: - Callbacks
    var onSaveButtonTapped: (() -> Void)? = nil
    var onCancelButtonTapped: (() -> Void)? = nil
    
    private var previousTouchLocation: CGPoint?
    private var activeEdgeView: ActiveEdgeView?
    private var cancellables = Set<AnyCancellable>()
    private let viewModel: RingtoneEditViewModel
    
    // MARK: - Methods
    init(viewModel: RingtoneEditViewModel) {
        self.viewModel = viewModel
        super.init()
        setBackgroundColorAndView()
        constructHierarchy()
        configureButtonTargets()
        configureTextField()
        observeViewModel()
    }
}

// MARK: - Style
extension RingtoneEditView {
    private func setBackgroundColorAndView() {
        backgroundColor = .clear
        
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(visualEffectView)
        NSLayoutConstraint.activate([
            visualEffectView.leftAnchor.constraint(equalTo: leftAnchor),
            visualEffectView.rightAnchor.constraint(equalTo: rightAnchor),
            visualEffectView.topAnchor.constraint(equalTo: topAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: - Hierarchy
extension RingtoneEditView {
    private func constructHierarchy() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        // Textfield
        stackView.addArrangedSubview(textField)
        
        // Waveform
        stackView.addArrangedSubview(waveformView)
        
        // Controls
        stackView.addArrangedSubview(controlsStackView)
        let leftSpacer = UIView()
        controlsStackView.addArrangedSubview(leftSpacer)
        controlsStackView.addArrangedSubview(saveButton)
        controlsStackView.addArrangedSubview(cancelButton)
        controlsStackView.addArrangedSubview(playPauseButton)
        NSLayoutConstraint.activate([
            playPauseButton.widthAnchor.constraint(equalTo: playPauseButton.heightAnchor)
        ])
        let rightSpacer = UIView()
        controlsStackView.addArrangedSubview(rightSpacer)
        NSLayoutConstraint.activate([
            leftSpacer.widthAnchor.constraint(equalTo: rightSpacer.widthAnchor),
            saveButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor),
        ])
        
        zoomOutButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(zoomOutButton)
        NSLayoutConstraint.activate([
            zoomOutButton.leftAnchor.constraint(equalTo: waveformView.leftAnchor, constant: 8),
            zoomOutButton.topAnchor.constraint(equalTo: waveformView.topAnchor)
        ])
        
        zoomInButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(zoomInButton)
        NSLayoutConstraint.activate([
            zoomInButton.rightAnchor.constraint(equalTo: waveformView.rightAnchor, constant: -8),
            zoomInButton.topAnchor.constraint(equalTo: waveformView.topAnchor)
        ])
        
        // Hanldes
        leftEdgeView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(leftEdgeView, at: 1)
        let leftEdgeViewConstraint = leftEdgeView.rightAnchor.constraint(equalTo: stackView.leftAnchor)
        self.leftEdgeViewConstraint = leftEdgeViewConstraint
        NSLayoutConstraint.activate([
            leftEdgeViewConstraint,
            leftEdgeView.heightAnchor.constraint(equalTo: waveformView.heightAnchor),
            leftEdgeView.centerYAnchor.constraint(equalTo: waveformView.centerYAnchor),
            leftEdgeView.widthAnchor.constraint(equalToConstant: 1)
        ])
        
        rightEdgeView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(rightEdgeView, at: 1)
        let rightEdgeViewConstraint = rightEdgeView.leftAnchor.constraint(equalTo: stackView.rightAnchor)
        self.rightEdgeViewConstraint = rightEdgeViewConstraint
        NSLayoutConstraint.activate([
            rightEdgeViewConstraint,
            rightEdgeView.heightAnchor.constraint(equalTo: waveformView.heightAnchor),
            rightEdgeView.centerYAnchor.constraint(equalTo: waveformView.centerYAnchor),
            rightEdgeView.widthAnchor.constraint(equalToConstant: 1)
        ])
        
        // Overlay
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(overlayView, at: 0)
        NSLayoutConstraint.activate([
            overlayView.leftAnchor.constraint(equalTo: leftEdgeView.rightAnchor),
            overlayView.rightAnchor.constraint(equalTo: rightEdgeView.leftAnchor),
            overlayView.heightAnchor.constraint(equalTo: waveformView.heightAnchor),
            overlayView.centerYAnchor.constraint(equalTo: waveformView.centerYAnchor)
        ])
        
        // Timing Labels
        leftTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(leftTimeLabel)
        NSLayoutConstraint.activate([
            leftTimeLabel.leftAnchor.constraint(equalTo: waveformView.leftAnchor, constant: 8),
            leftTimeLabel.bottomAnchor.constraint(equalTo: waveformView.bottomAnchor)
        ])
        
        rightTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(rightTimeLabel)
        NSLayoutConstraint.activate([
            rightTimeLabel.rightAnchor.constraint(equalTo: waveformView.rightAnchor, constant: -8),
            rightTimeLabel.bottomAnchor.constraint(equalTo: waveformView.bottomAnchor)
        ])
    }
}

// MARK: - Button Actions
extension RingtoneEditView {
    private func configureButtonTargets() {
        saveButton.addTarget(self, action: #selector(onSave), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(onCancel), for: .touchUpInside)
        zoomInButton.addTarget(self, action: #selector(onZoomIn), for: .touchUpInside)
        zoomOutButton.addTarget(self, action: #selector(onZoomOut), for: .touchUpInside)
    }
    
    @objc private func onSave() {
        onSaveButtonTapped?()
    }
    
    @objc private func onCancel() {
        onCancelButtonTapped?()
    }
    
    @objc private func onZoomIn() {
        
    }
    
    @objc private func onZoomOut() {
        
    }
}

// MARK: - Touches Handling
extension RingtoneEditView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let touch = touches.first else { return }
        
        let touchLocation = touch.location(in: self)
        
        if previousTouchLocation == nil {
            previousTouchLocation = touchLocation
        }
        
        let leftEdgeX = leftEdgeView.frame.midX
        let rightEdgeX = rightEdgeView.frame.midX
        
        let distanceToLeftEdge = abs(touchLocation.x - leftEdgeX)
        let distanceToRightEdge = abs(touchLocation.x - rightEdgeX)
        
        if distanceToLeftEdge < distanceToRightEdge {
            activeEdgeView = .left(xPosition: leftEdgeViewConstraint?.constant ?? 0)
        } else {
            activeEdgeView = .right(xPosition: rightEdgeViewConstraint?.constant ?? 0)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        guard let edgeView = activeEdgeView else { return }
        guard let touch = touches.first else { return }
        
        let touchLocation = touch.location(in: self)
        
        guard let previousTouchLocation = previousTouchLocation
        else { return }
        
        //        let locationInWaveformView = touch.location(in: waveformView)
        //        let centerY = waveformView.bounds.height / 2
        //        let fractionFromCenter = 1 - abs(locationInWaveformView.y - centerY) / (centerY)
        //        let scrabbingFactor = max(0.2, fractionFromCenter)
        //
        //        let translation = (touchLocation.x - previousTouchLocation.x) * scrabbingFactor
        
        let translation = touchLocation.x - previousTouchLocation.x
        
        switch edgeView {
        case .left(let xPosition):
            let newConstant = xPosition + translation
            
            let (start, end) = calculateStartAndEndPositions(
                leftConstant: newConstant,
                rightConstant: rightEdgeViewConstraint?.constant
            )
            
            guard viewModel.selectTrimmingPositions(startPosition: start, endPosition: end)
            else {
                self.previousTouchLocation = touchLocation
                return
            }
            
            if newConstant >= 0 {
                leftEdgeViewConstraint?.constant = newConstant
                activeEdgeView = .left(xPosition: newConstant)
            } else {
                leftEdgeViewConstraint?.constant = 0
                activeEdgeView = .left(xPosition: 0)
                
                viewModel.resetStartTrimmingPosition()
            }
            
            layoutIfNeeded()
            
            self.previousTouchLocation = touchLocation
        case .right(let xPosition):
            let newConstant = xPosition + translation
            
            let (start, end) = calculateStartAndEndPositions(
                leftConstant: leftEdgeViewConstraint?.constant,
                rightConstant: newConstant
            )
            
            guard viewModel.selectTrimmingPositions(startPosition: start, endPosition: end)
            else {
                self.previousTouchLocation = touchLocation
                return
            }
            
            if newConstant <= 0 {
                rightEdgeViewConstraint?.constant = newConstant
                activeEdgeView = .right(xPosition: newConstant)
            } else {
                rightEdgeViewConstraint?.constant = 0
                activeEdgeView = .right(xPosition: 0)
                
                viewModel.resetEndTrimmingPosition()
            }
            
            layoutIfNeeded()
            
            self.previousTouchLocation = touchLocation
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        activeEdgeView = nil
        previousTouchLocation = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        activeEdgeView = nil
        previousTouchLocation = nil
    }
}

// MARK: - Start and End Positions
extension RingtoneEditView {
    private func calculateStartAndEndPositions(leftConstant: CGFloat?, rightConstant: CGFloat?) -> (start: Double, end: Double) {
        let waveformWidth = waveformView.bounds.width
        
        let overlayViewOriginX = leftConstant ?? 0
        let overlayViewEndX = waveformWidth + (rightConstant ?? 0)
        
        let start = Double(overlayViewOriginX / waveformWidth)
        let end = Double(overlayViewEndX / waveformWidth)
        
        let validStart = max(0, start)
        let validEnd = min(1, end)
        
        return (validStart, validEnd)
    }
}

// MARK: - TextField, UITextFieldDelegate
extension RingtoneEditView: UITextFieldDelegate {
    private func configureTextField() {
        textField.delegate = self
        textField.text = viewModel.title
        
        textField.addTarget(self, action: #selector(onTextFieldEditingChanged), for: .editingChanged)
    }
    
    @objc private func onTextFieldEditingChanged(_ textField: UITextField) {
        guard let title = textField.text else { return }
        
        setViewModelTitle(title)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}

// MARK: - View Model
extension RingtoneEditView {
    private func observeViewModel() {
        viewModel.$startTime
            .removeDuplicates()
            .sink { [weak self] startTime in
                guard let self = self else { return }
                
                self.leftTimeLabel.text = startTime
            }
            .store(in: &cancellables)
        
        viewModel.$endTime
            .removeDuplicates()
            .sink { [weak self] endTime in
                guard let self = self else { return }
                
                self.rightTimeLabel.text = endTime
            }
            .store(in: &cancellables)
        
        viewModel.$waveform
            .sink { [weak self] waveform in
                guard let self = self else { return }
                
                self.waveformView.setWaveform(waveform)
            }
            .store(in: &cancellables)
    }
    
    private func setViewModelTitle(_ title: String) {
        viewModel.title = title
    }
}
