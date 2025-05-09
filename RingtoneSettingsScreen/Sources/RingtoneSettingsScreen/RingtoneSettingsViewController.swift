//
//  RingtoneSettingsViewController.swift
//  RingtoneSettingsScreen
//
//  Created by Sargis Khachatryan on 09.05.25.
//

import RingtoneUIKit

public final class RingtoneSettingsViewController: NiblessViewController {
    // MARK: - Methods
    public override func loadView() {
        view = RingtoneSettingsView()
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
