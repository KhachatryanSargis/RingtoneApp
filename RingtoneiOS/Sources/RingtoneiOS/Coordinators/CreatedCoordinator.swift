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
                case .export(let audio):
                    print(audio)
                case .edit(let audio):
                    print(audio)
                }
            }
        storeCancellable(cancellable)
    }
    
    private func showImportMenu() {
        let alertController = UIAlertController(
            title: "Import Media",
            message: "Choose a source to import media from.",
            preferredStyle: .actionSheet
        )
        
        let importFromGalleryAction = RingtoneAlertAction(
            title: "Import from Gallery",
            style: .default
        ) {
            [weak self] _ in
            
            guard let self = self else { return }
            
            self.onImportFromGallery()
        }
        
        let importFromFilesAction = RingtoneAlertAction(
            title: "Import from Files",
            style: .default
        ) {
            [weak self] _ in
            
            guard let self = self else { return }
            
            self.onImportFromFiles()
        }
        
        let cancelAction = RingtoneAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil
        )
        
        alertController.addAction(importFromGalleryAction)
        alertController.addAction(importFromFilesAction)
        alertController.addAction(cancelAction)
        
        presentable.toViewController().present(
            alertController,
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
