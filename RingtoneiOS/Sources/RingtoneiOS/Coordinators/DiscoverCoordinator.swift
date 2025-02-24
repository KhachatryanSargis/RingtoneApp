//
//  DiscoverCoordinator.swift
//  RingtoneiOS
//
//  Created by Sargis Khachatryan on 25.02.25.
//

import RingtoneUIKit

final class DiscoverCoordinator: BaseCoordinator {
    private let navigationController: RingtoneNavigationController
    override var presentable: any Presentable {
        return navigationController
    }
    
    private let container: AppDependencyContainer
    
    init(container: AppDependencyContainer) {
        self.container = container
        let ringtoneDiscoverViewController = container.makeRingtoneDiscoverViewController()
        navigationController = RingtoneNavigationController(rootViewController: ringtoneDiscoverViewController)
        super.init()
    }
}
