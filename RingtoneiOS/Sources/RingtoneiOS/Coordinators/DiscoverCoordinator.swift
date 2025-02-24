class DiscoverCoordinator: BaseCoordinator {
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