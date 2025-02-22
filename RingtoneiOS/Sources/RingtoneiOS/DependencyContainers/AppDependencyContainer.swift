//
//  AppDependencyContainer.swift
//  RingtoneiOS
//
//  Created by Sargis Khachatryan on 22.02.25.
//

import RingtoneDiscoverScreen
import RingtoneFavoritesScreen
import RingtoneCreatedScreen

public final class AppDependencyContainer {
    public init () {}
}

// MARK: - RingtoneDiscoverViewController
extension AppDependencyContainer {
    @MainActor
    internal func makeRingtoneDiscoverViewController() -> RingtoneDiscoverViewController {
        RingtoneDiscoverViewController()
    }
}

// MARK: - Ringtone
extension AppDependencyContainer {
    @MainActor
    internal func makeRingtoneFavoritesViewController() -> RingtoneFavoritesViewController {
        RingtoneFavoritesViewController()
    }
}

// MARK: - Ringtone
extension AppDependencyContainer {
    @MainActor
    internal func makeRingtoneCreatedViewController() -> RingtoneCreatedViewController {
        RingtoneCreatedViewController()
    }
}
