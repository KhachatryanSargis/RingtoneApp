//
//  FavoritesCoordinator.swift
//  RingtoneiOS
//
//  Created by Sargis Khachatryan on 25.02.25.
//

import RingtoneUIKit

final class FavoritesCoordinator: BaseCoordinator {
    private let navigationController: RingtoneNavigationController
    override var presentable: any Presentable {
        return navigationController
    }
    
    private let container: AppDependencyContainer
    
    init(container: AppDependencyContainer) {
        self.container = container
        let ringtoneFavoritesViewController = container.makeRingtoneFavoritesViewController()
        navigationController = RingtoneNavigationController(rootViewController: ringtoneFavoritesViewController)
        super.init()
    }
}
