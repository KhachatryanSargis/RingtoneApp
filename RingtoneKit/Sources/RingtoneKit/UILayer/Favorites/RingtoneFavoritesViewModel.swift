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
    
    private var cancellables: Set<AnyCancellable> = []
    
    private let audioPlayer: IRingtoneAudioPlayer
    private let favoriteAudiosMediator: RingtoneFavoriteAudiosMediator
    
    // MARK: - Methods
    public init(
        audioPlayer: IRingtoneAudioPlayer,
        favoriteAudiosMediator: RingtoneFavoriteAudiosMediator
    ) {
        self.audioPlayer = audioPlayer
        self.favoriteAudiosMediator = favoriteAudiosMediator
        
        observeFavoriteAudios()
        observeAudioPlayerStatus()
    }
    
    private func observeFavoriteAudios() {
        favoriteAudiosMediator.favoriteAudiosPublisher
            .sink { [weak self] favoriteAudios in
                guard let self = self else { return }
                
                // Syncing playback status.
                if let currentAudioID = self.audioPlayer.currentAudioID,
                   let index = audios.firstIndex(where: { $0.id == currentAudioID }) {
                    audios[index] = audios[index].played()
                }
                
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
        print("ringtoneAudioEdit")
    }
}

// MARK: - Export
extension RingtoneFavoritesViewModel: RingtoneAudioExportResponder {
    public func exportRingtoneAudio(_ audio: RingtoneAudio) {
        print("exportRingtoneAudio")
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
    
    private func observeAudioPlayerStatus() {
        audioPlayer.statusPublisher
            .sink { [weak self] status in
                guard let self = self else { return }
                
                switch status {
                case .startedPlaying(let audioID):
                    var audios = self.audios
                    
                    // TODO: Optimize.
                    for (index, audio) in self.audios.enumerated() {
                        if audioID == audio.id  {
                            audios[index] = audios[index].played()
                        } else {
                            audios[index] = audios[index].paused()
                        }
                    }
                    
                    self.audios = audios
                default:
                    self.audios = self.audios.map { $0.paused() }
                }
            }
            .store(in: &cancellables)
    }
}
