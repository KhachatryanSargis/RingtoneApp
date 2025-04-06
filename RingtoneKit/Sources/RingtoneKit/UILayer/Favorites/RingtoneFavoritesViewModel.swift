//
//  RingtoneFavoritesViewModel.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 01.03.25.
//

import Combine

public protocol RingtoneFavoritesViewModelFactory {
    func makeRingtoneFavoritesViewModelFactory() -> RingtoneFavoritesViewModel
}

public final class RingtoneFavoritesViewModel {
    // MARK: - Properties
    @Published public private(set) var audios: [RingtoneAudio] = []
    @Published public private(set) var action: RingtoneFavoritesAction?
    
    private var cancellables: Set<AnyCancellable> = []
    
    private let audioPlayer: IRingtoneAudioPlayer
    private let favoriteAudiosMediator: RingtoneFavoriteAudiosMediator
    private let dataExporterFactory: () -> IRingtoneDataExporter
    
    // MARK: - Methods
    public init(
        audioPlayer: IRingtoneAudioPlayer,
        favoriteAudiosMediator: RingtoneFavoriteAudiosMediator,
        dataExporterFactory: @escaping () -> IRingtoneDataExporter
    ) {
        self.audioPlayer = audioPlayer
        self.favoriteAudiosMediator = favoriteAudiosMediator
        self.dataExporterFactory = dataExporterFactory
        
        observeFavoriteAudios()
    }
    
    private func observeFavoriteAudios() {
        favoriteAudiosMediator.favoriteAudiosPublisher
            .sink { [weak self] favoriteAudios in
                guard let self = self else { return }
                
                self.audios = favoriteAudios
            }
            .store(in: &cancellables)
    }
}

// MARK: - Favorite
extension RingtoneFavoritesViewModel: RingtoneAudioFavoriteStatusChangeResponder {
    public func changeAudioFavoriteStatus(_ audio: RingtoneAudio) {
        favoriteAudiosMediator.changeAudioFavoriteStatus(audio)
    }
}

// MARK: - Edit
extension RingtoneFavoritesViewModel: RingtoneAudioEditResponder {
    public func editRingtoneAudio(_ audio: RingtoneAudio) {
        self.action = .editAudio(audio)
    }
}

// MARK: - Export
extension RingtoneFavoritesViewModel: RingtoneAudioExportResponder {
    public func exportRingtoneAudio(_ audio: RingtoneAudio) {
        exportRingtoneAudios([audio])
    }
    
    public func exportRingtoneAudios(_ audios: [RingtoneAudio]) {
        let dataExporter = dataExporterFactory()
        
        return dataExporter.exportRingtoneAudios(audios)
            .sink { [weak self] result in
                guard let self = self else { return }
                
                let urls = result.completeItems.map { $0.url }
                
                self.action = .exportGarageBandProjects(urls)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Playback
extension RingtoneFavoritesViewModel: RingtoneAudioPlaybackStatusChangeResponder {
    public func changeRingtoneAudioPlaybackStatus(_ audio: RingtoneAudio) {
        if audio.isPlaying {
            audioPlayer.pause()
        } else {
            audioPlayer.play(audio)
        }
    }
}
