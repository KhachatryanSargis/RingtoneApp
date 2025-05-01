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
    private var hideProgresstimer: Timer?
    
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

// MARK: - Hide / Show Progress, Set Progress
extension RingtoneTabBarController {
    private func hideProgress() {
        guard !progressView.isHidden else { return }
        
        let animator = UIViewPropertyAnimator(duration: 0.5, curve: .linear) { [weak self] in
            guard let self = self else { return }
            
            self.progressView.alpha = 0
        }
        
        animator.addCompletion { [weak self] _ in
            guard let self = self else { return }
            
            self.progressView.isHidden = true
        }
        
        animator.startAnimation()
    }
    
    private func setProgress(_ progress: Float) {
        let animated = progress != 0
        
        let changes = { [weak self] in
            guard let self = self else { return }
            
            if progress != 0 && self.progressView.isHidden {
                self.progressView.alpha = 1
                self.progressView.isHidden = false
            }
            
            if progress == 1 && !self.progressView.isHidden {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.hideProgress()
                }
            }
            
            self.progressView.setProgress(Float(progress), animated: animated)
        }
        
        if animated {
            let animator = UIViewPropertyAnimator(duration: 0.1, curve: .linear) {
                changes()
            }
            
            animator.startAnimation()
        } else {
            changes()
        }
    }
}

// MARK: - Hide Progress Timer
extension RingtoneTabBarController {
    private func startHideProgressTimer() {
        hideProgresstimer?.invalidate()
        
        let timer = Timer.scheduledTimer(
            timeInterval: 3,
            target: self,
            selector: #selector(onHideProgress),
            userInfo: nil,
            repeats: false
        )
        
        RunLoop.main.add(timer, forMode: .common)
        
        self.hideProgresstimer = timer
    }
    
    @objc private func onHideProgress() {
        stopHideProgressTimer()
        
        hideProgress()
    }
    
    private func stopHideProgressTimer() {
        hideProgresstimer?.invalidate()
        hideProgresstimer = nil
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
                
                self.stopHideProgressTimer()
                
                self.setProgress(0)
            }, receiveValue: { [weak self] progress in
                guard let self = self else { return }
                
                self.startHideProgressTimer()
                
                self.setProgress(progress)
            })
            .store(in: &cancellables)
    }
}
