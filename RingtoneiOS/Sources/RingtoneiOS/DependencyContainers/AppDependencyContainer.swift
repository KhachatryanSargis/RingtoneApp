//
//  AppDependencyContainer.swift
//  RingtoneiOS
//
//  Created by Sargis Khachatryan on 22.02.25.
//

import Foundation
import RingtoneKit
import RingtoneDiscoverScreen
import RingtoneFavoritesScreen
import RingtoneCreatedScreen
import RingtoneImportScreens
import RingtoneEditScreen

public final class AppDependencyContainer {
    // MARK: - Properties
    var audioPlayerProgressPublisher: IRingtoneAudioPlayerProgressPublisher {
        return audioPlayer
    }
    
    private let audioPlayer: RingtoneAudioPlayer
    private let discoverViewModel: RingtoneDiscoverViewModel
    private let favoritesViewModel: RingtoneFavoritesViewModel
    private let createdViewModel: RingtoneCreatedViewModel
    private let importViewModel: RingtoneImportViewModel
    
    // MARK: - Methods
    public init () {
        let ringtoneAudioPlayer = RingtoneAudioPlayer()
        self.audioPlayer = ringtoneAudioPlayer
        
        let ringtoneCategoriesRepository = RingtoneCategoriesRepository(
            store: RingtoneCategoriesStore()
        )
        
        let ringtoneAudioRepository = RingtoneAudioRepository(
            store: RingtoneAudioStore(),
            audioPlayerStatusPublisher: ringtoneAudioPlayer
        )
        
        let dataImporterFactory = { RingtoneDataImporter() }
        
        let dataConverterFactory = { RingtoneDataConverter() }
        
        let dataExporterFactory = { RingtoneDataExporter() }
        
        let dataDownloaderFactory = { (url: URL) -> IRingtoneDataDownloader in
            if SocialMediaDataDownloader.isSupportedHost(url: url) {
                return SocialMediaDataDownloader()
            } else {
                return RingtoneDataDownloader()
            }
        }
        
        favoritesViewModel = RingtoneFavoritesViewModel(
            audioPlayer: ringtoneAudioPlayer,
            favoriteAudiosMediator: ringtoneAudioRepository,
            dataExporterFactory: dataExporterFactory
        )
        
        discoverViewModel = RingtoneDiscoverViewModel(
            audioPlayer: ringtoneAudioPlayer,
            discoverAudiosMediator: ringtoneAudioRepository,
            categoreisRepository: ringtoneCategoriesRepository,
            dataExporterFactory: dataExporterFactory
        )
        
        importViewModel = RingtoneImportViewModel(
            dataImporterFactory: dataImporterFactory,
            dataDownloaderFactory: dataDownloaderFactory,
            dataConverterFactory: dataConverterFactory
        )
        
        createdViewModel = RingtoneCreatedViewModel(
            audioPlayer: ringtoneAudioPlayer,
            createdAudiosMediator: ringtoneAudioRepository,
            audioImportResponder: importViewModel,
            dataExporterFactory: dataExporterFactory
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
        RingtoneImportFromFilesViewController(viewModelFactory: self)
    }
    
    @MainActor
    internal func makeRingtoneImportFromGalleryViewController() -> RingtoneImportFromGalleryViewController {
        RingtoneImportFromGalleryViewController(viewModelFactory: self)
    }
    
    @MainActor
    internal func makeRingtoneImportFromURLViewController() -> RingtoneImportFromURLViewController {
        RingtoneImportFromURLViewController(viewModelFactory: self)
    }
    
    public func makeRingtoneImportViewModel() -> RingtoneImportViewModel {
        importViewModel
    }
}

// MARK: - Edit
extension AppDependencyContainer {
    @MainActor
    internal func makeRingtoneEditViewController(audio: RingtoneAudio) -> RingtoneEditViewController {
        audioPlayer.stop()
        
        let viewModel = RingtoneEditViewModel(
            audio: audio,
            audioPlayer: RingtoneAudioPlayer(),
            dataEditor: RingtoneDataEditor()
        )
        
        return RingtoneEditViewController(viewModel: viewModel)
    }
}
