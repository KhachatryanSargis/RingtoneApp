//
//  RingtoneFavoritesViewController.swift
//  RingtoneFavoritesScreen
//
//  Created by Sargis Khachatryan on 22.02.25.
//

import UIKit
import RingtoneUIKit

public final class RingtoneFavoritesViewController: NiblessViewController {
    public override init(enableKeyboardNotificationObservers: Bool = false) {
        super.init(enableKeyboardNotificationObservers: enableKeyboardNotificationObservers)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBarItem()
        configureNavigationItem()
        view.backgroundColor = .systemBackground
    }
}

// MARK: - Tab Bar Item
extension RingtoneFavoritesViewController {
    private func configureTabBarItem() {
        guard let tabBarItem = tabBarItem else { return }
        tabBarItem.title = "Favorites"
        tabBarItem.image = UIImage(systemName: "heart.square")
    }
}

// MARK: - Navigation Item
extension RingtoneFavoritesViewController {
    private func configureNavigationItem() {
        navigationItem.title = String(
            localized: "Favorites",
            comment: "The title of the ringtone favorites screen."
        )
    }
}
