//
//  AppCoordinator.swift
//  RingtoneiOS
//
//  Created by Sargis Khachatryan on 22.02.25.
//

import RingtoneUIKit

public final class AppCoordinator: BaseCoordinator {
    // MARK: - Properties
    private let tabBarController = NiblessTabBarController()
    public override var presentable: any Presentable {
        return tabBarController
    }
    
    private let container: AppDependencyContainer
    
    // MARK: - Methods
    public init(container: AppDependencyContainer) {
        self.container = container
        super.init()
    }
    
    public override func start() {
        super.start()
        tabBarController.view.backgroundColor = .red
    }
}
