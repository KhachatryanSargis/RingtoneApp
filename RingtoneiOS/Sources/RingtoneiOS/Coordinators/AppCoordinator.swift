//
//  AppCoordinator.swift
//  RingtoneiOS
//
//  Created by Sargis Khachatryan on 22.02.25.
//

import RingtoneUIKit

public final class AppCoordinator: BaseCoordinator {
    // MARK: - Properties
    private let tabBarController: RingtoneTabBarController
    public override var presentable: any Presentable {
        return tabBarController
    }
    
    private let container: AppDependencyContainer
    
    // MARK: - Methods
    public init(container: AppDependencyContainer) {
        self.container = container
        self.tabBarController = RingtoneTabBarController()
        super.init()
    }
    
    public override func start() {
        super.start()
        
        let ringtoneDiscoverViewController = container.makeRingtoneDiscoverViewController()
        let ringtoneFavoritesViewController = container.makeRingtoneFavoritesViewController()
        let ringtoneCreatedViewController = container.makeRingtoneCreatedViewController()
        
        tabBarController.addChild(ringtoneDiscoverViewController)
        tabBarController.addChild(ringtoneFavoritesViewController)
        tabBarController.addChild(ringtoneCreatedViewController)
        
        // TODO: come up with a better way to preload child view controllers.
        _ = ringtoneDiscoverViewController.view
        _ = ringtoneFavoritesViewController.view
        _ = ringtoneCreatedViewController.view
    }
}
