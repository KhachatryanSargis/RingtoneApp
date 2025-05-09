//
//  RingtoneFavoritesViewController.swift
//  RingtoneFavoritesScreen
//
//  Created by Sargis Khachatryan on 22.02.25.
//

import UIKit
import Combine
import RingtoneUIKit
import RingtoneKit

public final class RingtoneFavoritesViewController: NiblessViewController {
    // MARK: - Properties
    public var actionPublisher: AnyPublisher<RingtoneFavoritesAction, Never> {
        actionSubject.eraseToAnyPublisher()
    }
    private let actionSubject = PassthroughSubject<RingtoneFavoritesAction, Never>()
    private var cancellables = Set<AnyCancellable>()
    private let viewModelFactory: RingtoneFavoritesViewModelFactory
    
    // MARK: - Methods
    public init(viewModelFactory: RingtoneFavoritesViewModelFactory) {
        self.viewModelFactory = viewModelFactory
        super.init(enableKeyboardNotificationObservers: false)
    }
    
    public override func loadView() {
        let viewModel = viewModelFactory.makeRingtoneFavoritesViewModelFactory()
        
        observeViewModelAction(viewModel)
        
        view = RingtoneFavoritesView(viewModel: viewModel)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBarItem()
        configureNavigationItem()
    }
}

// MARK: - Tab Bar Item
extension RingtoneFavoritesViewController {
    private func configureTabBarItem() {
        guard let tabBarItem = tabBarItem else { return }
        tabBarItem.title = "Favorites"
        tabBarItem.image = .theme.favorites
    }
}

// MARK: - Navigation Item
extension RingtoneFavoritesViewController {
    private func configureNavigationItem() {
        navigationItem.title = String(
            localized: "Favorites",
            comment: "The title of the ringtone favorites screen."
        )
        
        navigationItem.setLeftBarButton(
            createUsageTutorialButtonItem(),
            animated: false
        )
    }
    
    private func createUsageTutorialButtonItem() -> UIBarButtonItem {
        UIBarButtonItem(
            image: .theme.usage,
            style: .plain,
            target: self,
            action: #selector(onUsageTutorial)
        )
    }
    
    @objc
    private func onUsageTutorial() {
        actionSubject.send(.showUsageTutorial)
    }
}

// MARK: - View Model Actions
extension RingtoneFavoritesViewController {
    private func observeViewModelAction(_ viewModel: RingtoneFavoritesViewModel) {
        viewModel.$action
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] action in
                guard let self = self else { return }
                
                switch action {
                case .exportGarageBandProject(let url, let audio):
                    self.actionSubject.send(.exportGarageBandProject(url, audio))
                case .exportAudios(let audios):
                    self.actionSubject.send(.exportAudios(audios))
                case .editAudio(let audio):
                    self.actionSubject.send(.editAudio(audio))
                case .showUsageTutorial:
                    self.actionSubject.send(.showUsageTutorial)
                }
            }
            .store(in: &cancellables)
    }
}
