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
        self.tabBarController = RingtoneTabBarController(
            audioPlayerProgressPublisher: container.audioPlayerProgressPublisher
        )
        super.init()
    }
    
    public override func start() {
        super.start()
        
        let createdCoordinator = CreatedCoordinator(container: container)
        addChild(createdCoordinator)
        
        let favoritesCoordinator = FavoritesCoordinator(container: container)
        addChild(favoritesCoordinator)
        
        let settingsCoordinator = SettingsCoordinator(container: container)
        addChild(settingsCoordinator)
    }
}
