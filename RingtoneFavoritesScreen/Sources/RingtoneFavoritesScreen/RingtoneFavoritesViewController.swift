//
//  RingtoneFavoritesViewController.swift
//  RingtoneFavoritesScreen
//
//  Created by Sargis Khachatryan on 22.02.25.
//

import UIKit
import RingtoneUIKit
import RingtoneKit

public final class RingtoneFavoritesViewController: NiblessViewController {
    // MARK: - Properties
    private let viewModelFactory: RingtoneFavoritesViewModelFactory
    
    // MARK: - Methods
    public init(viewModelFactory: RingtoneFavoritesViewModelFactory) {
        self.viewModelFactory = viewModelFactory
        super.init(enableKeyboardNotificationObservers: false)
    }
    
    public override func loadView() {
        let viewModel = viewModelFactory.makeRingtoneFavoritesViewModelFactory()
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
    }
}
