//
//  RingtoneFavoritesViewModel.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 01.03.25.
//

import Foundation
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
        let dataExporter = dataExporterFactory()
        
        dataExporter.createGarageBandProject(from: audio)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                guard case .failure(let error) = completion else { return }
                
                print(error)
            } receiveValue: { [weak self] url in
                guard let self = self else { return }
                
                self.action = .exportGarageBandProject(url, audio)
            }
            .store(in: &cancellables)
    }
    
    public func exportRingtoneAudios(_ audios: [RingtoneAudio]) {
        action = .exportAudios(audios)
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
