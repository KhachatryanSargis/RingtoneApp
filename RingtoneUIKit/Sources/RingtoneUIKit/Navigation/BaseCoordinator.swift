//
//  BaseCoordinator.swift
//  ChallengeiOS
//
//  Created by Sargis Khachatryan on 13.02.25.
//

import UIKit
import Combine

open class BaseCoordinator: Coordinator {
    // MARK: - Properties
    public private(set) final var children: [AnyCancellable : any Coordinator]
    public private(set) final var statePublisher: CurrentValueSubject<CoordinatorState, Never>
    open private(set) var presentable: Presentable
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Methods
    public init() {
        self.children = [:]
        self.presentable = NiblessNavigationController()
        statePublisher = .init(.initialized)
    }
    
    open func start() {
        statePublisher.send(.started)
    }
    
    public final func toViewController() -> UIViewController {
        return presentable.toViewController()
    }
}

// MARK: - Add Child
extension BaseCoordinator {
    public final func addChild(
        _ coordinator: Coordinator,
        modalPresentationStyle: UIModalPresentationStyle = .automatic,
        completion: (() -> Void)? = nil
    ) {
        coordinator.start()
        
        if let tabBarController = toViewController() as? RingtoneTabBarController {
            tabBarController.addChild(coordinator.toViewController())
        } else {
            coordinator.toViewController().modalPresentationStyle = modalPresentationStyle
            
            presentable.toViewController().present(
                coordinator.toViewController(),
                animated: true,
                completion: completion
            )
        }
        
        let cancellable = coordinator.statePublisher
            .sink { [weak self] state in
                guard let self = self else { return }
                switch state {
                case .finished:
                    self.removeChild(coordinator)
                default:
                    return
                }
            }
        cancellable.store(in: &cancellables)
        
        children[cancellable] = coordinator
    }
}

// MARK: - Remove Child
extension BaseCoordinator {
    private func removeChild(_ coordinator: Coordinator) {
        children.forEach { (key, value) in
            if value.toViewController() === coordinator.toViewController() {
                children.removeValue(forKey: key)
                cancellables.remove(key)
                key.cancel()
            }
        }
    }
}

// MARK: - Finish
extension BaseCoordinator {
    public final func finish() {
        guard !presentable.toViewController().isBeingDismissed
        else {
            self.statePublisher.send(.finished)
            return
        }
        
        guard let presentingViewController = presentable.toViewController().presentingViewController
        else { return }
        presentingViewController.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.statePublisher.send(.finished)
        }
    }
}

// MARK: - Show Alert
extension BaseCoordinator {
    public func showAlert(title: String, message: String) {
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        presentable.toViewController().present(alertViewController, animated: true)
        let action = UIAlertAction(title: "Ok", style: .cancel)
        alertViewController.addAction(action)
    }
}

// MARK: - Cancellables
extension BaseCoordinator {
    public func storeCancellable(_ cancellable: AnyCancellable) {
        cancellables.insert(cancellable)
    }
}
