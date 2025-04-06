//
//  RingtoneImportFromURLView.swift
//  RingtoneImportScreens
//
//  Created by Sargis Khachatryan on 26.03.25.
//

import UIKit
import Combine
import RingtoneUIKit
import RingtoneKit

final class RingtoneImportFromURLView: NiblessView {
    // MARK: - Properties
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .theme.headline
        label.textColor = .theme.label
        label.text = "Enter an Audio or Video Link"
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    
    private let disclaimerLabel: UILabel = {
        let label = UILabel()
        label.font = .theme.subheadline
        label.textColor = .theme.secondaryLabel
        label.text = "Please ensure that the files you download do not violate the rights of others. Copyrighted cannot should not be downloaded using this tool."
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .theme.secondaryBackground
        return textField
    }()
    
    private let startButton: UIButton = {
        var configuration = UIButton.Configuration.borderedTinted()
        configuration.imagePlacement = .top
        configuration.image = .theme.download
        configuration.title = "Start"
        return UIButton(configuration: configuration)
    }()
    
    private let progressView: RingtoneProgressView = {
        let progressView = RingtoneProgressView(frame: .zero)
        return progressView
    }()
    
    private var cancellables = Set<AnyCancellable>()
    private let viewModel: RingtoneImportViewModel
    
    // MARK: - Methods
    init(viewModel: RingtoneImportViewModel) {
        self.viewModel = viewModel
        super.init()
        setBackgroundColor()
        constructHierarchy()
        configureButtonTargets()
        setTextFieldDelegate()
        setViewState(isDownloading: false, animated: false)
    }
    
    func finish() {
        setViewState(isDownloading: false, animated: true)
    }
    
    private func setViewState(isDownloading: Bool, animated: Bool) {
        let closure = { [weak self] in
            guard let self = self else { return }
            
            self.progressView.isHidden = isDownloading ? false : true
            self.progressView.alpha = isDownloading ? 1 : 0
            
            self.startButton.isEnabled = isDownloading ? false : true
            
            self.textField.isEnabled = isDownloading ? false : true
        }
        
        if animated {
            let animator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.5) {
                closure()
            }
            animator.startAnimation()
        } else {
            closure()
        }
    }
    
    private func setProgress(_ progress: Progress) {
        let progressCGFloat: CGFloat = CGFloat(progress.fractionCompleted)
        progressView.setProgress(to: progressCGFloat)
    }
}

// MARK: - Style
extension RingtoneImportFromURLView {
    private func setBackgroundColor() {
        backgroundColor = .theme.background
    }
}

// MARK: - Hierarchy
extension RingtoneImportFromURLView {
    private func constructHierarchy() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
            stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -8),
            stackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8)
        ])
        
        stackView.addArrangedSubview(progressView)
        NSLayoutConstraint.activate([
            progressView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            progressView.heightAnchor.constraint(equalTo: progressView.widthAnchor)
        ])
        
        stackView.addArrangedSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor)
        ])
        
        stackView.setCustomSpacing(8, after: titleLabel)
        
        stackView.addArrangedSubview(disclaimerLabel)
        NSLayoutConstraint.activate([
            disclaimerLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor)
        ])
        
        stackView.addArrangedSubview(textField)
        NSLayoutConstraint.activate([
            textField.widthAnchor.constraint(equalTo: stackView.widthAnchor)
        ])
        
        stackView.addArrangedSubview(startButton)
    }
}

// MARK: - Button Actions
extension RingtoneImportFromURLView {
    private func configureButtonTargets() {
        startButton.addTarget(self, action: #selector(onStart), for: .touchUpInside)
    }
    
    @objc
    private func onStart() {
        guard let urlString = textField.text,
              let url = URL(string: urlString)
        else { return }
        
        textField.resignFirstResponder()
        
        setViewState(isDownloading: true, animated: true)
        
        progressView.startPulsingAnimation()
        
        viewModel.downloadFromUrl(url)
            .sink { [weak self] progress in
                guard let self = self else { return }
                
                self.progressView.stopPulsingAnimation()
                
                self.setProgress(progress)
            }
            .store(in: &cancellables)
    }
}

// MARK: - UITextFieldDelegate
extension RingtoneImportFromURLView: UITextFieldDelegate {
    private func setTextFieldDelegate() {
        textField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
