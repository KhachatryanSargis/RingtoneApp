//
//  FavoritesCoordinator.swift
//  RingtoneiOS
//
//  Created by Sargis Khachatryan on 25.02.25.
//

import UIKit
import Combine
import RingtoneUIKit
import RingtoneKit

final class FavoritesCoordinator: BaseCoordinator {
    private let navigationController: RingtoneNavigationController
    override var presentable: any Presentable {
        return navigationController
    }
    
    private let container: AppDependencyContainer
    
    init(container: AppDependencyContainer) {
        self.container = container
        let ringtoneFavoritesViewController = container.makeRingtoneFavoritesViewController()
        navigationController = RingtoneNavigationController(rootViewController: ringtoneFavoritesViewController)
        super.init()
        
        observeRingtoneFavotiesActions(ringtoneFavoritesViewController.actionPublisher)
    }
}

// MARK: - Actions
extension FavoritesCoordinator {
    private func observeRingtoneFavotiesActions(_ publisher: AnyPublisher<RingtoneFavoritesAction, Never>) {
        let cancellable = publisher
            .compactMap { $0 }
            .sink { [weak self] action in
                guard let self = self else { return }
                
                switch action {
                case .exportGarageBandProject(let url, let audio):
                    self.onExportGarageBandProject(url, audio)
                case .exportAudios(let audios):
                    self.onExportAudios(audios)
                case .editAudio(let audio):
                    self.onEditAudio(audio)
                case .showUsageTutorial:
                    self.onShowUsageTutorial()
                }
            }
        storeCancellable(cancellable)
    }
}

// MARK: - Edit
extension FavoritesCoordinator {
    private func onEditAudio(_ audio: RingtoneAudio) {
        let ringtoneEditViewController = container.makeRingtoneEditViewController(audio: audio)
        let navigationController = NiblessNavigationController(rootViewController: ringtoneEditViewController)
        navigationController.modalPresentationStyle = .overFullScreen
        navigationController.modalTransitionStyle = .crossDissolve
        presentable.toViewController().present(
            navigationController,
            animated: true
        )
    }
}

// MARK: - Export
extension FavoritesCoordinator {
    private func onExportGarageBandProject(_ url: URL, _ audio: RingtoneAudio) {
        let waveform = audio.decodeWaveform()
        
        if waveform.duration > 30 {
            let warningAlertController = UIAlertController.warningAlertController { [weak self] in
                guard let self = self else { return }
                
                self.onEditAudio(audio)
            } onContinue: { [weak self] in
                guard let self = self else { return }
                
                self.exportURLs([url])
            }
            
            presentable.toViewController().present(
                warningAlertController,
                animated: true,
                completion: nil
            )
        } else {
            exportURLs([url])
        }
    }
    
    private func onExportAudios(_ audios: [RingtoneAudio]) {
        let urls = audios.map { $0.url }
        
        guard !urls.isEmpty else { return }
        
        exportURLs(urls)
    }
    
    private func exportURLs(_ urls: [URL]) {
        let activityViewController = UIActivityViewController(
            activityItems: urls,
            applicationActivities: nil
        )
        
        presentable.toViewController().present(
            activityViewController,
            animated: true,
            completion: nil
        )
    }
}

// MARK: - Tutorial
extension FavoritesCoordinator {
    private func onShowUsageTutorial() {
        let ringtoneUsageTutorialViewController = container.makeRingtoneUsageTutorialViewController()
        let navigationController = NiblessNavigationController(rootViewController: ringtoneUsageTutorialViewController)
        presentable.toViewController().present(
            navigationController,
            animated: true,
            completion: nil
        )
    }
}
