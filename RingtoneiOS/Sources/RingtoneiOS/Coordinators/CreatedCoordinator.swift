//
//  CreatedCoordinator.swift
//  RingtoneiOS
//
//  Created by Sargis Khachatryan on 25.02.25.
//

import UIKit
import Combine
import RingtoneUIKit
import RingtoneKit

final class CreatedCoordinator: BaseCoordinator {
    private let navigationController: RingtoneNavigationController
    override var presentable: any Presentable {
        return navigationController
    }
    
    private let container: AppDependencyContainer
    
    init(container: AppDependencyContainer) {
        self.container = container
        let ringtoneCreatedViewController = container.makeRingtoneCreatedViewController()
        navigationController = RingtoneNavigationController(rootViewController: ringtoneCreatedViewController)
        super.init()
        
        observeRingtoneCreatedActions(ringtoneCreatedViewController.actionPublisher)
    }
}

// MARK: - Actions
extension CreatedCoordinator {
    private func observeRingtoneCreatedActions(_ publisher: AnyPublisher<RingtoneCreatedAction, Never>) {
        let cancellable = publisher
            .compactMap { $0 }
            .sink { [weak self] action in
                guard let self = self else { return }
                
                switch action {
                case .importAudio:
                    self.showImportMenu()
                case .importAudioFromGallery:
                    self.onImportFromGallery()
                case .importAudioFromFiles:
                    self.onImportFromFiles()
                case .importAudioFromURL:
                    self.onImportFromURL()
                case .exportGarageBandProjects(let urls):
                    self.onExportGarageBandProjects(urls)
                case .editAudio(let audio):
                    self.onEditAudio(audio)
                }
            }
        storeCancellable(cancellable)
    }
}

// MARK: - Import Alert Controller
extension CreatedCoordinator {
    private func showImportMenu() {
        let importAlertController = UIAlertController.importAlertController { [weak self] in
            guard let self = self else { return }
            
            self.onImportFromGallery()
        } fromFiles: { [weak self] in
            guard let self = self else { return }
            
            self.onImportFromFiles()
        } fromURL: { [weak self] in
            guard let self = self else { return }
            
            self.onImportFromURL()
        }
        
        presentable.toViewController().present(
            importAlertController,
            animated: true,
            completion: nil
        )
    }
}

// MARK: - Import From Gallery
extension CreatedCoordinator {
    private func onImportFromGallery() {
        let ringtoneImportFromGalleryViewController = container.makeRingtoneImportFromGalleryViewController()
        presentable.toViewController().present(
            ringtoneImportFromGalleryViewController,
            animated: true
        )
    }
}

// MARK: - Import From Files
extension CreatedCoordinator {
    private func onImportFromFiles() {
        let ringtoneImportFromFilesViewController = container.makeRingtoneImportFromFilesViewController()
        presentable.toViewController().present(
            ringtoneImportFromFilesViewController,
            animated: true
        )
    }
}

// MARK: - Import From URL
extension CreatedCoordinator {
    private func onImportFromURL() {
        let ringtoneImportFromURLViewController = container.makeRingtoneImportFromURLViewController()
        let navigationController = NiblessNavigationController(rootViewController: ringtoneImportFromURLViewController)
        presentable.toViewController().present(
            navigationController,
            animated: true
        )
    }
}

// MARK: - Edit
extension CreatedCoordinator {
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
extension CreatedCoordinator {
    private func onExportGarageBandProjects(_ urls: [URL]) {
        guard !urls.isEmpty else { return }
        
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
