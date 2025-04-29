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
        case left
        case right
    }
    
    // MARK: - Callbacks
    var onSaveButtonTapped: (() -> Void)? = nil
    var onCancelButtonTapped: (() -> Void)? = nil
    
    // MARK: - Properties
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
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
    
    // MARK: - Edge Views
    private let leftOverlayView: RingtoneGradientView = {
        let color: UIColor = .theme.secondaryBackground.withAlphaComponent(0.5)
        let gradientView = RingtoneGradientView(color: color)
        return gradientView
    }()
    
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
    
    private let rightOverlayView: UIView = {
        let color: UIColor = .theme.secondaryBackground.withAlphaComponent(0.5)
        let gradientView = RingtoneGradientView(color: color)
        return gradientView
    }()
    
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
    private let timeLabelsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let leftTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .theme.headline.monospace()
        label.textColor = .theme.secondaryLabel
        label.textAlignment = .left
        return label
    }()
    
    private let rightTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .theme.headline.monospace()
        label.textColor = .theme.secondaryLabel
        label.textAlignment = .right
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.font = .theme.headline.monospace()
        label.textColor = .theme.secondaryLabel
        label.textAlignment = .center
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
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.setImage(.theme.delete, for: .normal)
        button.tintColor = .theme.red
        return button
    }()
    
    private let zoomButtonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
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
    
    private let resetButton: UIButton = {
        var configuration = UIButton.Configuration.tinted()
        configuration.image = .theme.reset
        let button = UIButton(configuration: configuration)
        return button
    }()
    
    private let fadeSteppersView: RingtoneFadeSteppersView = {
        let fadeSteppersView = RingtoneFadeSteppersView()
        return fadeSteppersView
    }()
    
    private var previousTouchLocation: CGPoint?
    private var activeEdgeView: ActiveEdgeView?
    private var cancellables = Set<AnyCancellable>()
    private let viewModel: RingtoneEditViewModel
    
    // MARK: - Methods
    init(viewModel: RingtoneEditViewModel) {
        self.viewModel = viewModel
        super.init()
        isUserInteractionEnabled = true
        setBackgroundColorAndView()
        constructHierarchy()
        configureButtonTargets()
        configureTextField()
        observeViewModel()
        bindFadeStepperValues()
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
        
        // Fade Steppers
        stackView.addArrangedSubview(fadeSteppersView)
        
        // Waveform
        stackView.addArrangedSubview(waveformView)
        
        // Controls
        stackView.addArrangedSubview(controlsStackView)
        let leftSpacer = UIView()
        controlsStackView.addArrangedSubview(leftSpacer)
        controlsStackView.addArrangedSubview(deleteButton)
        NSLayoutConstraint.activate([
            deleteButton.widthAnchor.constraint(equalTo: deleteButton.heightAnchor)
        ])
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
        
        zoomButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(zoomButtonsStackView)
        NSLayoutConstraint.activate([
            zoomButtonsStackView.rightAnchor.constraint(equalTo: waveformView.rightAnchor, constant: -8),
            zoomButtonsStackView.topAnchor.constraint(equalTo: waveformView.topAnchor)
        ])
        zoomButtonsStackView.addArrangedSubview(zoomOutButton)
        zoomButtonsStackView.addArrangedSubview(zoomInButton)
        
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(resetButton)
        NSLayoutConstraint.activate([
            resetButton.leftAnchor.constraint(equalTo: waveformView.leftAnchor, constant: 8),
            resetButton.topAnchor.constraint(equalTo: waveformView.topAnchor)
        ])
        
        // Edge Views
        leftEdgeView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(leftEdgeView)
        let leftEdgeViewConstraint = leftEdgeView.rightAnchor.constraint(equalTo: waveformView.leftAnchor)
        self.leftEdgeViewConstraint = leftEdgeViewConstraint
        NSLayoutConstraint.activate([
            leftEdgeViewConstraint,
            leftEdgeView.heightAnchor.constraint(equalTo: waveformView.heightAnchor, multiplier: 0.8),
            leftEdgeView.centerYAnchor.constraint(equalTo: waveformView.centerYAnchor),
            leftEdgeView.widthAnchor.constraint(equalToConstant: 1)
        ])
        
        leftOverlayView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(leftOverlayView)
        NSLayoutConstraint.activate([
            leftOverlayView.leftAnchor.constraint(equalTo: leftAnchor),
            leftOverlayView.rightAnchor.constraint(equalTo: leftEdgeView.leftAnchor),
            leftOverlayView.heightAnchor.constraint(equalTo: waveformView.heightAnchor, multiplier: 0.8),
            leftOverlayView.centerYAnchor.constraint(equalTo: waveformView.centerYAnchor)
        ])
        
        rightEdgeView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(rightEdgeView)
        let rightEdgeViewConstraint = rightEdgeView.leftAnchor.constraint(equalTo: waveformView.rightAnchor)
        self.rightEdgeViewConstraint = rightEdgeViewConstraint
        NSLayoutConstraint.activate([
            rightEdgeViewConstraint,
            rightEdgeView.heightAnchor.constraint(equalTo: waveformView.heightAnchor, multiplier: 0.8),
            rightEdgeView.centerYAnchor.constraint(equalTo: waveformView.centerYAnchor),
            rightEdgeView.widthAnchor.constraint(equalToConstant: 1)
        ])
        
        rightOverlayView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(rightOverlayView)
        NSLayoutConstraint.activate([
            rightOverlayView.rightAnchor.constraint(equalTo: rightAnchor),
            rightOverlayView.leftAnchor.constraint(equalTo: rightEdgeView.rightAnchor),
            rightOverlayView.heightAnchor.constraint(equalTo: waveformView.heightAnchor, multiplier: 0.8),
            rightOverlayView.centerYAnchor.constraint(equalTo: waveformView.centerYAnchor)
        ])
        
        // Timing Labels
        timeLabelsStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(timeLabelsStackView)
        NSLayoutConstraint.activate([
            timeLabelsStackView.leftAnchor.constraint(equalTo: waveformView.leftAnchor, constant: 8),
            timeLabelsStackView.rightAnchor.constraint(equalTo: waveformView.rightAnchor, constant: -8),
            timeLabelsStackView.bottomAnchor.constraint(equalTo: waveformView.bottomAnchor)
        ])
        timeLabelsStackView.addArrangedSubview(leftTimeLabel)
        timeLabelsStackView.addArrangedSubview(durationLabel)
        timeLabelsStackView.addArrangedSubview(rightTimeLabel)
    }
}

// MARK: - Button Actions
extension RingtoneEditView {
    private func configureButtonTargets() {
        saveButton.addTarget(self, action: #selector(onSave), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(onCancel), for: .touchUpInside)
        zoomInButton.addTarget(self, action: #selector(onZoomIn), for: .touchUpInside)
        zoomOutButton.addTarget(self, action: #selector(onZoomOut), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(onReset), for: .touchUpInside)
        playPauseButton.addTarget(self, action: #selector(onPlayOrPause), for: .touchUpInside)
    }
    
    @objc private func onSave() {
        onSaveButtonTapped?()
    }
    
    @objc private func onCancel() {
        onCancelButtonTapped?()
    }
    
    @objc private func onZoomIn() {
        viewModel.zoomIn()
    }
    
    @objc private func onZoomOut() {
        viewModel.zoomOut()
    }
    
    @objc private func onReset() {
        viewModel.resetZoom()
    }
    
    @objc private func onPlayOrPause() {
        viewModel.togglePlayback()
    }
}

// MARK: - Touches Handling
extension RingtoneEditView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let touch = touches.first else { return }
        
        guard waveformView.bounds.contains(
            touch.location(in: waveformView)
        ) else { return }
        
        let touchLocation = touch.location(in: self)
        
        previousTouchLocation = touchLocation
        
        let leftEdgeX = leftEdgeView.frame.midX
        let rightEdgeX = rightEdgeView.frame.midX
        
        let distanceToLeftEdge = abs(touchLocation.x - leftEdgeX)
        let distanceToRightEdge = abs(touchLocation.x - rightEdgeX)
        
        if distanceToLeftEdge < distanceToRightEdge {
            activeEdgeView = .left
        } else {
            activeEdgeView = .right
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        guard let edgeView = activeEdgeView else { return }
        guard let touch = touches.first else { return }
        
        let touchLocation = touch.location(in: self)
        
        guard let previousTouchLocation = previousTouchLocation
        else { return }
        
        let translation = (touchLocation.x - previousTouchLocation.x) / waveformView.bounds.width
        
        switch edgeView {
        case .left:
            viewModel.adjustStartTime(by: translation)
        case .right:
            viewModel.adjustEndTime(by: translation)
        }
        
        self.previousTouchLocation = touchLocation
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

// MARK: - Observe View Model
extension RingtoneEditView {
    private func observeViewModel() {
        viewModel.$startTimeFormatted
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] startTime in
                guard let self = self else { return }
                
                self.leftTimeLabel.text = startTime
            }
            .store(in: &cancellables)
        
        viewModel.$endTimeFormatted
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] endTime in
                guard let self = self else { return }
                
                self.rightTimeLabel.text = endTime
            }
            .store(in: &cancellables)
        
        viewModel.$durationFormatted
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] duration in
                guard let self = self else { return }
                
                self.durationLabel.text = duration
            }
            .store(in: &cancellables)
        
        viewModel.$update
            .receive(on: DispatchQueue.main)
            .sink { [weak self] update in
                guard let self = self else { return }
                
                self.waveformView.setWaveform(update.waveform, animated: true)
                
                UIView.animate(withDuration: 0.2) {
                    let waveformWidth = self.waveformView.bounds.width
                    let leftConstant = waveformWidth * CGFloat(update.startPosition)
                    let rightConstant = -waveformWidth * CGFloat(1 - update.endPosition)
                    
                    self.leftEdgeViewConstraint?.constant = leftConstant
                    self.rightEdgeViewConstraint?.constant = rightConstant
                    
                    self.layoutIfNeeded()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$canZoomIn
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] canZoomIn in
                guard let self = self else { return }
                
                self.zoomInButton.isEnabled = canZoomIn
            }
            .store(in: &cancellables)
        
        viewModel.$canZoomOut
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] canZoomOut in
                guard let self = self else { return }
                
                self.zoomOutButton.isEnabled = canZoomOut
                self.resetButton.isEnabled = canZoomOut
            }
            .store(in: &cancellables)
        
        viewModel.$startPosition
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] startPosition in
                guard let self = self else { return }
                
                let waveformWidth = self.waveformView.bounds.width
                let constant = waveformWidth * CGFloat(startPosition)
                
                self.leftEdgeViewConstraint?.constant = constant
            }
            .store(in: &cancellables)
        
        viewModel.$endPosition
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] endPosition in
                guard let self = self else { return }
                
                let waveformWidth = self.waveformView.bounds.width
                let constant = -waveformWidth * CGFloat(1 - endPosition)
                
                self.rightEdgeViewConstraint?.constant = constant
            }
            .store(in: &cancellables)
        
        viewModel.$progress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
                guard let self = self else { return }
                
                self.waveformView.updatePlaybackProgress(
                    from: CGFloat(self.viewModel.startPosition),
                    to: CGFloat(self.viewModel.endPosition),
                    current: CGFloat(progress)
                )
            }
            .store(in: &cancellables)
        
        viewModel.$isPlaying
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isPlaying in
                guard let self = self else { return }
                
                if isPlaying {
                    self.playPauseButton.setImage(.theme.pause, for: .normal)
                } else {
                    self.playPauseButton.setImage(.theme.play, for: .normal)
                }
            }
            .store(in: &cancellables)
        
        viewModel.$maximumFadeDuration
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] duration in
                guard let self = self else { return }
                
                self.fadeSteppersView.setMaximumValue(duration)
            }
            .store(in: &cancellables)
        
        viewModel.$fadeInDuration
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                guard let self = self else { return }
                
                self.fadeSteppersView.setFadeInValue(value)
            }
            .store(in: &cancellables)
        
        viewModel.$fadeOutDuration
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                guard let self = self else { return }
                
                self.fadeSteppersView.setFadeOutValue(value)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Bind View Model
extension RingtoneEditView {
    private func setViewModelTitle(_ title: String) {
        viewModel.title = title
    }
    
    private func bindFadeStepperValues() {
        fadeSteppersView.$fadeInValue
            .removeDuplicates()
            .sink { [weak self] value in
                guard let self = self else { return }
                
                self.viewModel.fadeIn(duration: value)
            }
            .store(in: &cancellables)
        
        fadeSteppersView.$fadeOutValue
            .removeDuplicates()
            .sink { [weak self] value in
                guard let self = self else { return }
                
                self.viewModel.fadeOut(duration: value)
            }
            .store(in: &cancellables)
    }
}
