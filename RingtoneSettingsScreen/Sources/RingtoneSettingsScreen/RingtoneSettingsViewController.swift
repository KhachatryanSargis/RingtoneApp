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
