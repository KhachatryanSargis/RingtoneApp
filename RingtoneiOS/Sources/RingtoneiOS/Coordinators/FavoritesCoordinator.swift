class FavoritesCoordinator: BaseCoordinator {
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