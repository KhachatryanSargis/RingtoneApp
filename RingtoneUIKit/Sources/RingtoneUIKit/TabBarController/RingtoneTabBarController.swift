//
//  RingtoneTabBarController.swift
//  RingtoneUIKit
//
//  Created by Sargis Khachatryan on 22.02.25.
//

import UIKit
import Combine
import RingtoneKit

public final class RingtoneTabBarController: NiblessTabBarController {
    // MARK: - Properties
    private let progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressTintColor = .theme.accent
        progressView.trackTintColor = .clear
        return progressView
    }()
    
    private var cancellables: Set<AnyCancellable> = []
    private let audioPlayerProgressPublisher: IRingtoneAudioPlayerProgressPublisher
    
    // MARK: - Methods
    public init(audioPlayerProgressPublisher: IRingtoneAudioPlayerProgressPublisher) {
        self.audioPlayerProgressPublisher = audioPlayerProgressPublisher
        super.init()
        setTabBarAppearance()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setProgressBar()
        observeAudioPlayerProgress()
    }
    
    public override func addChild(_ childController: UIViewController) {
        super.addChild(childController)
        // TODO: Find a better way to preload child controller.
        if let navigationController = childController as? UINavigationController {
            _ = navigationController.topViewController?.view
        } else {
            _ = childController.view
        }
    }
}

// MARK: - Style
extension RingtoneTabBarController {
    private func setTabBarAppearance() {
        let appearance = UITabBarAppearance()
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
}

// MARK: - Progress
extension RingtoneTabBarController {
    private func setProgressBar() {
        progressView.translatesAutoresizingMaskIntoConstraints = false
        tabBar.addSubview(progressView)
        NSLayoutConstraint.activate([
            progressView.leftAnchor.constraint(equalTo: tabBar.leftAnchor),
            progressView.rightAnchor.constraint(equalTo: tabBar.rightAnchor),
            progressView.bottomAnchor.constraint(equalTo: tabBar.topAnchor)
        ])
    }
    
    private func observeAudioPlayerProgress() {
        audioPlayerProgressPublisher.progressPublisher
            .sink(receiveCompletion: { [weak self] _ in
                guard let self = self else { return }
                
                self.progressView.progress = 0
            }, receiveValue: { [weak self] progress in
                guard let self = self else { return }
                
                self.progressView.progress = Float(progress)
            })
            .store(in: &cancellables)
    }
}
