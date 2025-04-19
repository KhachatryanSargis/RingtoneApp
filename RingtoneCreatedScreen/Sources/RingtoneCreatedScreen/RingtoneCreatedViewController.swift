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

public final class RingtoneCreatedViewController: NiblessViewController {
    // MARK: - Properties
    private let exportDeleteView: RingtoneExportDeleteView = {
        let view = RingtoneExportDeleteView(frame: .zero)
        return view
    }()
    
    public var actionPublisher: AnyPublisher<RingtoneCreatedAction, Never> {
        actionSubject.eraseToAnyPublisher()
    }
    private let actionSubject = PassthroughSubject<RingtoneCreatedAction, Never>()
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
        
        observeViewModelAction(viewModel)
        observeViewModelLoading(viewModel)
        observeViewModelSelection(viewModel)
        
        view = RingtoneCreatedView(viewModel: viewModel)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBarItem()
        configureExportDeleteView()
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
        
        addMenuBarButtonItem()
    }
    
    private func createSelectAllBarButtonItem() -> UIBarButtonItem {
        return UIBarButtonItem(
            title: "Select All",
            style: .plain,
            target: self,
            action: #selector(onSelectAll)
        )
    }
    
    private func createDeselectAllBarButtonItem() -> UIBarButtonItem {
        return UIBarButtonItem(
            title: "Deselect All",
            style: .plain,
            target: self,
            action: #selector(onDeselectAll)
        )
    }
    
    private func createDoneBarButtonItem() -> UIBarButtonItem {
        return UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(onDone)
        )
    }
    
    @objc
    private func onSelectAll() {
        navigationItem.setLeftBarButton(
            createDeselectAllBarButtonItem(),
            animated: true
        )
        
        let viewModel = viewModelFactory.makeRingtoneCreatedViewModel()
        viewModel.selectAllRingtoneAudios()
    }
    
    @objc
    private func onDeselectAll() {
        navigationItem.setLeftBarButton(
            createSelectAllBarButtonItem(),
            animated: true
        )
        
        let viewModel = viewModelFactory.makeRingtoneCreatedViewModel()
        viewModel.deselectAllRingtoneAudios()
    }
    
    @objc
    private func onDone() {
        let viewModel = viewModelFactory.makeRingtoneCreatedViewModel()
        viewModel.deselectAllRingtoneAudios()
        viewModel.disableSelection()
    }
}

// MARK: - Menu
extension RingtoneCreatedViewController {
    private func createMenuBarButtonItem() -> UIBarButtonItem {
        let menu = UIMenu(
            title: "",
            children: [
                createSelectAction(),
                createImportFromGalleryAction(),
                createImportFromFilesAction(),
                createImportFromURLAction()
            ]
        )
        
        return UIBarButtonItem(
            image: .theme.menu,
            menu: menu
        )
    }
    
    private func createSelectAction() -> UIAction {
        let viewModel = viewModelFactory.makeRingtoneCreatedViewModel()
        
        let action = UIAction(title: "Select", image: .theme.select) { _ in
            viewModel.enableSelection()
        }
        
        if viewModel.canSelect {
            action.attributes = []
        } else {
            action.attributes = [.disabled]
        }
        
        return action
    }
    
    private func createImportFromGalleryAction() -> UIAction {
        UIAction(title: "Import From Gallery", image: .theme.gallery) {
            [weak self] _ in
            
            guard let self = self else { return }
            
            self.actionSubject.send(.importAudioFromGallery)
        }
    }
    
    private func createImportFromFilesAction() -> UIAction {
        UIAction(title: "Import From Files", image: .theme.files) {
            [weak self] _ in
            
            guard let self = self else { return }
            
            self.actionSubject.send(.importAudioFromFiles)
        }
    }
    
    private func createImportFromURLAction() -> UIAction {
        UIAction(title: "Download From a Link", image: .theme.link) {
            [weak self] _ in
            
            guard let self = self else { return }
            
            self.actionSubject.send(.importAudioFromURL)
        }
    }
    
    private func addMenuBarButtonItem(animated: Bool = false) {
        let menuBarButtonItem = createMenuBarButtonItem()
        navigationItem.setRightBarButton(
            menuBarButtonItem,
            animated: animated
        )
    }
    
    private func reloadMenuBarButtonItem() {
        addMenuBarButtonItem(animated: true)
    }
    
    private func disableMenuBarButtonItem() {
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func enableMenuBarButtonItem() {
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
}

// MARK: Export Delete Action View
extension RingtoneCreatedViewController {
    private func addExportDeleteViewOnTabBar(_ tabBar: UITabBar) {
        exportDeleteView.frame = tabBar.frame
        exportDeleteView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exportDeleteView)
        NSLayoutConstraint.activate([
            exportDeleteView.leftAnchor.constraint(equalTo: view.leftAnchor),
            exportDeleteView.rightAnchor.constraint(equalTo: view.rightAnchor),
            exportDeleteView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            exportDeleteView.heightAnchor.constraint(equalToConstant: tabBar.bounds.height)
        ])
        
        tabBar.alpha = 0
    }
    
    private func removeExportDeleteViewFromTabBar(_ tabBar: UITabBar) {
        exportDeleteView.removeFromSuperview()
        tabBar.alpha = 1
    }
    
    private func configureExportDeleteView() {
        exportDeleteView.onExportButtonTapped = { [weak self] in
            guard let self = self else { return }
            
            let viewModel = self.viewModelFactory.makeRingtoneCreatedViewModel()
            let audios = viewModel.audios.filter { $0.isSelected == true }
            
            viewModel.exportRingtoneAudios(audios)
        }
        
        exportDeleteView.onDeleteButtonTapped = { [weak self] in
            guard let self = self else { return }
            
            self.onDeleteButtonTapped()
        }
    }
    
    private func onDeleteButtonTapped() {
        let deleteAlertController = UIAlertController.deleteAlertController { [weak self] in
            guard let self = self else { return }
            let viewModel = self.viewModelFactory.makeRingtoneCreatedViewModel()
            let audios = viewModel.audios.filter { $0.isSelected == true }
            
            viewModel.deleteRingtoneAudios(audios)
        }
        
        present(deleteAlertController, animated: true)
    }
    
    private func enableExportDeleteView() {
        exportDeleteView.isEnabled = true
    }
    
    private func disableExportDeleteView() {
        exportDeleteView.isEnabled = false
    }
}


// MARK: - View Model Actions
extension RingtoneCreatedViewController {
    private func observeViewModelAction(_ viewModel: RingtoneCreatedViewModel) {
        viewModel.$action
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] action in
                guard let self = self else { return }
                
                switch action {
                case .importAudio:
                    self.actionSubject.send(.importAudio)
                case .importAudioFromGallery:
                    self.actionSubject.send(.importAudioFromGallery)
                case .importAudioFromFiles:
                    self.actionSubject.send(.importAudioFromFiles)
                case .importAudioFromURL:
                    self.actionSubject.send(.importAudioFromURL)
                case .exportGarageBandProjects(let urls):
                    self.actionSubject.send(.exportGarageBandProjects(urls))
                case .editAudio(let audio):
                    self.actionSubject.send(.editAudio(audio))
                }
            }
            .store(in: &cancelables)
    }
}

// MARK: - View Model Loading
extension RingtoneCreatedViewController {
    private func observeViewModelLoading(_ viewModel: RingtoneCreatedViewModel) {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] isLoading in
                guard let self = self else { return }
                
                if isLoading {
                    self.startLoading()
                    self.disableMenuBarButtonItem()
                } else {
                    self.stopLoading()
                    self.enableMenuBarButtonItem()
                }
            }
            .store(in: &cancelables)
    }
}

// MARK: - View Model Selection
extension RingtoneCreatedViewController {
    private func observeViewModelSelection(_ viewModel: RingtoneCreatedViewModel) {
        viewModel.$canSelect
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] canSelect in
                guard let self = self else { return }
                
                self.reloadMenuBarButtonItem()
            }
            .store(in: &cancelables)
        
        viewModel.$isSelectionEnabled
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] isSelectionEnabled in
                guard let self = self else { return }
                
                guard let tabBar = tabBarController?.tabBar
                else { return }
                
                if isSelectionEnabled {
                    self.addSelectionEnabledBarButtonItems()
                    self.addExportDeleteViewOnTabBar(tabBar)
                } else {
                    self.addSelectionDisabledBarButtonItems()
                    self.removeExportDeleteViewFromTabBar(tabBar)
                }
            }
            .store(in: &cancelables)
        
        viewModel.$hasSelectedAudios
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] hasSelectedAudios in
                guard let self = self else { return }
                
                if hasSelectedAudios {
                    self.enableExportDeleteView()
                } else {
                    self.disableExportDeleteView()
                }
            }
            .store(in: &cancelables)
    }
    
    private func addSelectionEnabledBarButtonItems() {
        self.navigationItem.setLeftBarButton(
            self.createSelectAllBarButtonItem(),
            animated: true
        )
        
        self.navigationItem.setRightBarButton(
            self.createDoneBarButtonItem(),
            animated: true
        )
    }
    
    private func addSelectionDisabledBarButtonItems() {
        self.navigationItem.setRightBarButton(
            createMenuBarButtonItem(),
            animated: true
        )
        
        self.navigationItem.setLeftBarButton(
            nil,
            animated: true
        )
    }
}
