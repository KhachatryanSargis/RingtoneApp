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
    private let audioRepository: IRingtoneAudioRepository
    
    // MARK: - Methods
    public init () {
        let ringtoneCategoriesStore = RingtoneCategoriesStore()
        self.categoreisRepository = RingtoneCategoriesRepository(store: ringtoneCategoriesStore)
        
        let ringtoneAudioStore = RingtoneAudioStore()
        self.audioRepository = RingtoneAudioRepository(store: ringtoneAudioStore)
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
        RingtoneDiscoverViewModel(
            categoreisRepository: categoreisRepository,
            audioRepository: audioRepository
        )
    }
}

// MARK: - Ringtone
extension AppDependencyContainer {
    @MainActor
    internal func makeRingtoneFavoritesViewController() -> RingtoneFavoritesViewController {
        RingtoneFavoritesViewController()
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
