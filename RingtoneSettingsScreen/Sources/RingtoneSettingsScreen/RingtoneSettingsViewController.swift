//
//  RingtoneSettingsViewController.swift
//  RingtoneSettingsScreen
//
//  Created by Sargis Khachatryan on 09.05.25.
//

import RingtoneUIKit
import RingtoneKit

public final class RingtoneSettingsViewController: NiblessViewController {
    // MARK: - Properties
    private let viewModelFactory: RingtoneSettingsViewModelFactory
    
    // MARK: - Methods
    public init(viewModelFactory: RingtoneSettingsViewModelFactory) {
        self.viewModelFactory = viewModelFactory
        super.init()
    }
    
    public override func loadView() {
        let viewModel = viewModelFactory.makeSettingsViewModel()
        view = RingtoneSettingsView(viewModel: viewModel)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBarItem()
        configureNavigationItem()
    }
}

// MARK: - Tab Bar Item
extension RingtoneSettingsViewController {
    private func configureTabBarItem() {
        guard let tabBarItem = tabBarItem else { return }
        tabBarItem.title = "Settings"
        tabBarItem.image = .theme.settings
    }
}

// MARK: - Navigation Item
extension RingtoneSettingsViewController {
    private func configureNavigationItem() {
        navigationItem.title = String(
            localized: "Settings",
            comment: "The title of the ringtone settings screen."
        )
    }
}
