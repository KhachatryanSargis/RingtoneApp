//
//  SettingsCoordinator.swift
//  RingtoneiOS
//
//  Created by Sargis Khachatryan on 09.05.25.
//

import RingtoneUIKit

final class SettingsCoordinator: BaseCoordinator {
    private let navigationController: RingtoneNavigationController
    override var presentable: any Presentable {
        return navigationController
    }
    
    private let container: AppDependencyContainer
    
    init(container: AppDependencyContainer) {
        self.container = container
        let ringtoneSettingsViewController = container.makeRingtoneSettingsViewController()
        navigationController = RingtoneNavigationController(rootViewController: ringtoneSettingsViewController)
        super.init()
    }
}
