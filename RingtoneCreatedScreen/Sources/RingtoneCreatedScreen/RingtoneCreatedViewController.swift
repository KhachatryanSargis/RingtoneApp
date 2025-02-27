//
//  RingtoneCreatedViewController.swift
//  RingtoneCreatedScreen
//
//  Created by Sargis Khachatryan on 22.02.25.
//

import UIKit
import Combine
import RingtoneImportScreens
import RingtoneUIKit
import RingtoneKit

public enum RingtoneCreatedViewControllerAction {
    case `import`
}

public final class RingtoneCreatedViewController: NiblessViewController {
    // MARK: - Properties
    @Published public private(set) var action: RingtoneCreatedViewControllerAction?
    private var cancelables: Set<AnyCancellable> = []
    private let viewModelFactory: RingtoneCreatedViewModelFactory
    
    // MARK: - Methods
    public init(viewModelFactory: RingtoneCreatedViewModelFactory) {
        self.viewModelFactory = viewModelFactory
        super.init()
        configureNavigationItem()
    }
    
    public override func loadView() {
        let viewModel = viewModelFactory.makeRingtoneCreatedViewModel()
        view = RingtoneCreatedView(viewModel: viewModel)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBarItem()
        observeViewAction()
    }
}

// MARK: - Tab Bar Item
extension RingtoneCreatedViewController {
    private func configureTabBarItem() {
        guard let tabBarItem = tabBarItem else { return }
        tabBarItem.title = "My Ringtones"
        tabBarItem.image = .theme.myRingtones
    }
}

// MARK: - Navigation Item
extension RingtoneCreatedViewController {
    private func configureNavigationItem() {
        navigationItem.title = String(
            localized: "My Ringtones",
            comment: "The title of the ringtone created screen."
        )
    }
}

// MARK: - View Action
extension RingtoneCreatedViewController {
    private func observeViewAction() {
        (view as! RingtoneCreatedView).$action
            .sink { [weak self] action in
                guard let self = self else { return }
                switch action {
                case .some(_):
                    self.showImportMenu()
                case .none:
                    return
                }
            }
            .store(in: &cancelables)
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
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func onImportFromGallery() {
        let ringtoneImportFromGalleryViewController = RingtoneImportFromGalleryViewController()
        present(ringtoneImportFromGalleryViewController, animated: true)
    }
    
    private func onImportFromFiles() {
        let ringtoneImportFromFilesViewController = RingtoneImportFromFilesViewController()
        present(ringtoneImportFromFilesViewController, animated: true)
    }
}
