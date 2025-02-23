//
//  RingtoneDiscoverViewController.swift
//  RingtoneDiscoverScreen
//
//  Created by Sargis Khachatryan on 22.02.25.
//

import UIKit
import RingtoneUIKit
import RingtoneKit

public final class RingtoneDiscoverViewController: NiblessViewController {
    // MARK: - Properties
    private let viewModelFactory: RingtoneDiscoverViewModelFactory
    
    // MARK: - Methods
    public init(viewModelFactory: RingtoneDiscoverViewModelFactory) {
        self.viewModelFactory = viewModelFactory
        super.init(enableKeyboardNotificationObservers: false)
    }
    
    public override func loadView() {
        let viewModel = viewModelFactory.makeRingtoneDiscoverViewModel()
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
        tabBarItem.image = UIImage(systemName: "waveform.badge.magnifyingglass")
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
