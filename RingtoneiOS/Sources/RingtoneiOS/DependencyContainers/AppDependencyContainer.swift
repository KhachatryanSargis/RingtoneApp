//
//  AppDependencyContainer.swift
//  RingtoneiOS
//
//  Created by Sargis Khachatryan on 22.02.25.
//

import RingtoneKit
import RingtoneDiscoverScreen
import RingtoneFavoritesScreen
import RingtoneCreatedScreen

public final class AppDependencyContainer {
    // MARK: - Properties
    private let categoreisRepository: IRingtoneCategoriesRepository
    
    // MARK: - Methods
    public init () {
        let ringtoneCategoriesStore = RingtoneCategoriesStore()
        self.categoreisRepository = RingtoneCategoriesRepository(store: ringtoneCategoriesStore)
    }
}

// MARK: - Discover
extension AppDependencyContainer: RingtoneDiscoverViewModelFactory {
    // MARK: - RingtoneDiscoverViewController
    @MainActor
    internal func makeRingtoneDiscoverViewController() -> RingtoneDiscoverViewController {
        RingtoneDiscoverViewController(viewModelFactory: self)
    }
    
    // MARK: - DiscoverViewModelFactory
    public func makeRingtoneDiscoverViewModel() -> RingtoneDiscoverViewModel {
        RingtoneDiscoverViewModel(categoreisRepository: categoreisRepository)
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
