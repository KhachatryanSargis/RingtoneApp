//
//  RingtoneCreatedViewController.swift
//  RingtoneCreatedScreen
//
//  Created by Sargis Khachatryan on 22.02.25.
//

import UIKit
import RingtoneUIKit
import RingtoneKit

public final class RingtoneCreatedViewController: NiblessViewController {
    // MARK: - Properties
    private let viewModelFactory: RingtoneCreatedViewModelFactory
    
    // MARK: - Methods
    public init(viewModelFactory: RingtoneCreatedViewModelFactory) {
        self.viewModelFactory = viewModelFactory
        super.init()
        configureNavigationItem()
    }
    
    public override func loadView() {
        let viewModel = viewModelFactory.makeRingtoneCreatedViewModel()
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
    }
}
