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
    
    private func createMenuBarButtonItem() -> UIBarButtonItem {
        let menu = UIMenu(
            title: "",
            children: [
                createSelectAction(),
                createImportFromGalleryAction(),
                createImportFromFilesAction()
            ]
        )
        
        return UIBarButtonItem(
            image: .theme.menu,
            menu: menu
        )
    }
    
    private func createSelectAllBarButtonItem() -> UIBarButtonItem {
        return UIBarButtonItem(
            title: "Select All",
            style: .plain,
            target: self,
            action: #selector(onSelectAll)
        )
    }
    
    @objc
    private func onSelectAll() {
        
    }
    
    private func createDoneBarButtonItem() -> UIBarButtonItem {
        return UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(onDone)
        )
    }
    
    @objc
    private func onDone() {
        self.navigationItem.setRightBarButton(
            self.createMenuBarButtonItem(),
            animated: true
        )
        
        self.navigationItem.setLeftBarButton(
            nil,
            animated: true
        )
    }
}

// MARK: - Menu Actions
extension RingtoneCreatedViewController {
    private func createSelectAction() -> UIAction {
        let action = UIAction(title: "Select", image: .theme.select) {
            [weak self] _ in
            
            guard let self = self else { return }
            
            self.navigationItem.setLeftBarButton(
                self.createSelectAllBarButtonItem(),
                animated: true
            )
            
            self.navigationItem.setRightBarButton(
                self.createDoneBarButtonItem(),
                animated: true
            )
        }
        
        let viewModel = viewModelFactory.makeRingtoneCreatedViewModel()
        
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
}

// MARK: - View Model Actions
extension RingtoneCreatedViewController {
    private func observeViewModelAction(_ viewModel: RingtoneCreatedViewModel) {
        viewModel.$action
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
                case .export(let audio):
                    self.actionSubject.send(.export(audio))
                case .edit(let audio):
                    self.actionSubject.send(.edit(audio))
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

// MARK: - View Model Loading
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
    }
}
