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
    private var viewModel: RingtoneDiscoverViewModel?
    
    // MARK: - Methods
    public init(viewModelFactory: RingtoneDiscoverViewModelFactory) {
        self.viewModelFactory = viewModelFactory
        super.init(enableKeyboardNotificationObservers: false)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBarItem()
        view.backgroundColor = .systemBackground
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
