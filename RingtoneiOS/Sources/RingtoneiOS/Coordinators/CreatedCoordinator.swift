//
//  CreatedCoordinator.swift
//  RingtoneiOS
//
//  Created by Sargis Khachatryan on 25.02.25.
//

import RingtoneUIKit

final class CreatedCoordinator: BaseCoordinator {
    private let navigationController: RingtoneNavigationController
    override var presentable: any Presentable {
        return navigationController
    }
    
    private let container: AppDependencyContainer
    
    init(container: AppDependencyContainer) {
        self.container = container
        let ringtoneCreatedViewController = container.makeRingtoneCreatedViewController()
        navigationController = RingtoneNavigationController(rootViewController: ringtoneCreatedViewController)
        super.init()
    }
}
