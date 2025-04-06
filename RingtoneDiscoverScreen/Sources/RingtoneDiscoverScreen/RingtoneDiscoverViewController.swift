//
//  RingtoneDiscoverViewController.swift
//  RingtoneDiscoverScreen
//
//  Created by Sargis Khachatryan on 22.02.25.
//

import UIKit
import Combine
import RingtoneUIKit
import RingtoneKit

public final class RingtoneDiscoverViewController: NiblessViewController {
    // MARK: - Properties
    private var cancellables: Set<AnyCancellable> = []
    private let viewModelFactory: RingtoneDiscoverViewModelFactory
    
    // MARK: - Methods
    public init(viewModelFactory: RingtoneDiscoverViewModelFactory) {
        self.viewModelFactory = viewModelFactory
        super.init(enableKeyboardNotificationObservers: false)
    }
    
    public override func loadView() {
        let viewModel = viewModelFactory.makeRingtoneDiscoverViewModel()
        
        observeViewModelAction(viewModel)
        
        view = RingtoneDiscoverView(viewModel: viewModel)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBarItem()
        configureNavigationItem()
    }
}

// MARK: - Tab Bar Item
extension RingtoneDiscoverViewController {
    private func configureTabBarItem() {
        guard let tabBarItem = tabBarItem else { return }
        tabBarItem.title = "Discover"
        tabBarItem.image = .theme.discover
    }
}

// MARK: - Navigation Item
extension RingtoneDiscoverViewController {
    private func configureNavigationItem() {
        navigationItem.title = String(
            localized: "Discover",
            comment: "The title of the ringtone discover screen."
        )
    }
}

// MARK: - View Model Actions
extension RingtoneDiscoverViewController {
    private func observeViewModelAction(_ viewModel: RingtoneDiscoverViewModel) {
        viewModel.$action
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] action in
                guard let self = self else { return }
                
                switch action {
                case .exportGarageBandProjects(let urls):
                    self.onExportGarageBandProjects(urls)
                case .editAudio(let audio):
                    print(audio)
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Export
extension RingtoneDiscoverViewController {
    private func onExportGarageBandProjects(_ urls: [URL]) {
        guard !urls.isEmpty else { return }
        
        let activityViewController = UIActivityViewController(
            activityItems: urls,
            applicationActivities: nil
        )
        
        present(activityViewController,animated: true,completion: nil)
    }
}
