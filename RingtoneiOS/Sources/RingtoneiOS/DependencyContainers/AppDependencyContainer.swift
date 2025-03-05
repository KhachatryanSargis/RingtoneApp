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
import RingtoneImportScreens

public final class AppDependencyContainer {
    // MARK: - Properties
    unowned private(set) var audioPlayerProgressPublisher: IRingtoneAudioPlayerProgressPublisher
    
    private let discoverViewModel: RingtoneDiscoverViewModel
    private let favoritesViewModel: RingtoneFavoritesViewModel
    private let createdViewModel: RingtoneCreatedViewModel
    private let importViewModel: RingtoneImportViewModel
    
    // MARK: - Methods
    public init () {
        let ringtoneCategoriesRepository = RingtoneCategoriesRepository(
            store: RingtoneCategoriesStore()
        )
        
        let ringtoneAudioRepository = RingtoneAudioRepository(
            store: RingtoneAudioStore()
        )
        
        let ringtoneAudioPlayer = RingtoneAudioPlayer()
        self.audioPlayerProgressPublisher = ringtoneAudioPlayer
        
        favoritesViewModel = RingtoneFavoritesViewModel(
            audioRepository: ringtoneAudioRepository,
            audioPlayer: ringtoneAudioPlayer
        )
        
        discoverViewModel = RingtoneDiscoverViewModel(
            categoreisRepository: ringtoneCategoriesRepository,
            audioRepository: ringtoneAudioRepository,
            audiofavoriteStatusChangeResponder: favoritesViewModel,
            audioPlayer: ringtoneAudioPlayer
        )
        
        let ringtoneAudioEditor = RingtoneAudioEditor()
        importViewModel = RingtoneImportViewModel(
            audioEditor: ringtoneAudioEditor,
            audioRepository: ringtoneAudioRepository
        )
        
        createdViewModel = RingtoneCreatedViewModel(
            audioRepository: ringtoneAudioRepository,
            audiofavoriteStatusChangeResponder: favoritesViewModel,
            audioPlayer: ringtoneAudioPlayer,
            audioImportResponder: importViewModel
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
        createdViewModel
    }
}

// MARK: - Import
extension AppDependencyContainer: RingtoneImportViewModelFactory {
    @MainActor
    internal func makeRingtoneImportFromFilesViewController() -> RingtoneImportFromFilesViewController {
        RingtoneImportFromFilesViewController()
    }
    
    @MainActor
    internal func makeRingtoneImportFromGalleryViewController() -> RingtoneImportFromGalleryViewController {
        RingtoneImportFromGalleryViewController(viewModelFactory: self)
    }
    
    public func makeRingtoneImportViewModel() -> RingtoneImportViewModel {
        importViewModel
    }
}
