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
        
        navigationItem.rightBarButtonItem = .init(
            image: .theme.import_fill,
            style: .plain,
            target: self,
            action: #selector(onImport)
        )
    }
    
    @objc
    private func onImport() {
        actionSubject.send(.importAudio)
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
                
                isLoading ? self.startLoading() : self.stopLoading()
            }
            .store(in: &cancelables)
    }
}
