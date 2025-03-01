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
    private let discoverViewModel: RingtoneDiscoverViewModel
    private let favoritesViewModel: RingtoneFavoritesViewModel
    
    // MARK: - Methods
    public init () {
        let ringtoneCategoriesRepository = RingtoneCategoriesRepository(
            store: RingtoneCategoriesStore()
        )
        
        let ringtoneAudioRepository = RingtoneAudioRepository(
            store: RingtoneAudioStore()
        )
        
        favoritesViewModel = RingtoneFavoritesViewModel(
            audioRepository: ringtoneAudioRepository
        )
        
        discoverViewModel = RingtoneDiscoverViewModel(
            categoreisRepository: ringtoneCategoriesRepository,
            audioRepository: ringtoneAudioRepository,
            audiofavoriteStatusChangeResponder: favoritesViewModel
        )
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
        return discoverViewModel
    }
}

// MARK: - Ringtone
extension AppDependencyContainer: RingtoneFavoritesViewModelFactory {
    @MainActor
    internal func makeRingtoneFavoritesViewController() -> RingtoneFavoritesViewController {
        RingtoneFavoritesViewController(viewModelFactory: self)
    }
    
    public func makeRingtoneFavoritesViewModelFactory() -> RingtoneFavoritesViewModel {
        return favoritesViewModel
    }
}

// MARK: - Created
extension AppDependencyContainer: RingtoneCreatedViewModelFactory {
    @MainActor
    internal func makeRingtoneCreatedViewController() -> RingtoneCreatedViewController {
        RingtoneCreatedViewController(viewModelFactory: self)
    }
    
    public func makeRingtoneCreatedViewModel() -> RingtoneCreatedViewModel {
        RingtoneCreatedViewModel()
    }
}
