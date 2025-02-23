//
//  RingtoneCreatedViewController.swift
//  RingtoneCreatedScreen
//
//  Created by Sargis Khachatryan on 22.02.25.
//

import UIKit
import RingtoneUIKit

public final class RingtoneCreatedViewController: NiblessViewController {
    public override init(enableKeyboardNotificationObservers: Bool = false) {
        super.init(enableKeyboardNotificationObservers: enableKeyboardNotificationObservers)
        configureNavigationItem()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBarItem()
        view.backgroundColor = .systemBackground
    }
}

// MARK: - Tab Bar Item
extension RingtoneCreatedViewController {
    private func configureTabBarItem() {
        guard let tabBarItem = tabBarItem else { return }
        tabBarItem.title = "My Ringtones"
        tabBarItem.image = UIImage(systemName: "music.note.house")
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
