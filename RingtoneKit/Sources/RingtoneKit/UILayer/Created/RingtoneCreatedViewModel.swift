//
//  RingtoneCreatedViewModel.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 24.02.25.
//

import Combine

public protocol RingtoneCreatedViewModelFactory {
    func makeRingtoneCreatedViewModel() -> RingtoneCreatedViewModel
}

public final class RingtoneCreatedViewModel {
    // MARK: - Properties
    @Published public private(set) var isLoading: Bool = false
    @Published public private(set) var action: RingtoneCreatedAction?
    @Published public private(set) var audios: [RingtoneAudio] = []
    
    public let audioFavoriteStatusChangeResponder: RingtoneAudioFavoriteStatusChangeResponder
    public let audioImportResponder: RingtoneAudioImportResponder
    private let audioPlayer: IRingtoneAudioPlayer
    private var cancellables: Set<AnyCancellable> = []
    private let audioRepository: IRingtoneAudioRepository
    
    // MARK: - Methods
    public init(
        audioRepository: IRingtoneAudioRepository,
        audiofavoriteStatusChangeResponder: RingtoneAudioFavoriteStatusChangeResponder,
        audioPlayer: IRingtoneAudioPlayer,
        audioImportResponder: RingtoneAudioImportResponder
    ) {
        self.audioRepository = audioRepository
        self.audioFavoriteStatusChangeResponder = audiofavoriteStatusChangeResponder
        self.audioPlayer = audioPlayer
        self.audioImportResponder = audioImportResponder
        
        getCreatedRingtoneAudios()
        observeFavoriteAudios()
        observeAudioPlayerStatus()
        observeImportedAudios()
    }
    
    public func clearFailedRingtoneAudios() {
        audios.removeAll(where: { $0.failedToImport || $0.failedToConvert })
        audioImportResponder.clearAll()
    }
    
    public func retryFailedRingtoneAudio(_ audio: RingtoneAudio) {
        audios.removeAll(where: { $0.id == audio.id })
        audioImportResponder.clearByID(audio.id)
    }
    
    public func retryFailedRingtoneAudios() {
        audios.removeAll(where: { $0.failedToImport || $0.failedToConvert })
        audioImportResponder.retryAll()
    }
    
    public func cleanFailedRingtoneAudio(_ audio: RingtoneAudio) {
        audios.removeAll(where: { $0.id == audio.id })
        audioImportResponder.retryByID(audio.id)
    }
}

// MARK: - Get Created Ringtones
extension RingtoneCreatedViewModel {
    private func getCreatedRingtoneAudios() {
        audioRepository.getCreatedRingtoneAudios()
            .sink { completion in
                guard case .failure(let error) = completion else { return }
                print(error)
            } receiveValue: { [weak self] audios in
                guard let self = self else { return }
                
                var audios = audios
                
                // Syncing playback status.
                if let currentAudioID = self.audioPlayer.currentAudioID,
                   let index = audios.firstIndex(where: { $0.id == currentAudioID }) {
                    audios[index] = audios[index].played()
                }
                
                self.audios = audios
            }
            .store(in: &cancellables)
    }
}

// MARK: - Import
extension RingtoneCreatedViewModel {
    public func importRingtoneAudio() {
        action = .importAudio
    }
    
    private func observeImportedAudios() {
        audioImportResponder.audiosPublisher
            .sink { [weak self] audios in
                guard let self = self else { return }
                
                // Removing already exiting audios (loading).
                var currentAudios = self.audios
                let newAudioIDs = audios.map { $0.id }
                currentAudios.removeAll(where: { newAudioIDs.contains($0.id) })
                
                self.audios = currentAudios + audios
            }
            .store(in: &cancellables)
        
        audioImportResponder.isLoadingPublisher
            .sink { [weak self] isLoading in
                guard let self = self else { return }
                self.isLoading = isLoading
            }
            .store(in: &cancellables)
    }
}

// MARK: - Sync Favorite Audios
extension RingtoneCreatedViewModel {
    private func observeFavoriteAudios() {
        audioFavoriteStatusChangeResponder.audiosPublisher
            .sink { [weak self] favoriteAudios in
                guard let self = self else { return }
                
                var audios = self.audios
                
                for (index, audio) in audios.enumerated() {
                    if let favoriteIndex = favoriteAudios.firstIndex(where: { audio.id == $0.id }) {
                        audios[index] = favoriteAudios[favoriteIndex]
                    } else {
                        audios[index] = audio.unliked()
                    }
                }
                
                self.audios = audios
            }
            .store(in: &cancellables)
    }
}

// MARK: - RingtoneAudioPlaybackStatusChangeResponder
extension RingtoneCreatedViewModel: RingtoneAudioPlaybackStatusChangeResponder {
    public func ringtoneAudioPlaybackStatusChange(_ audio: RingtoneAudio) {
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
                case .pausedPlaying:
                    self.audios = self.audios.map { $0.paused() }
                case .finishedPlaying:
                    self.audios = self.audios.map { $0.paused() }
                case .failedToPlay:
                    self.audios = self.audios.map { $0.paused() }
                case .failedToInitialize(_):
                    self.audios = self.audios.map { $0.paused() }
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Export
extension RingtoneCreatedViewModel: RingtoneAudioExportResponder {
    public func exportRingtoneAudio(_ audio: RingtoneAudio) {
        action = .export(audio)
    }
}

// MARK: - Edit
extension RingtoneCreatedViewModel: RingtoneAudioEditResponder {
    public func ringtoneAudioEdit(_ audio: RingtoneAudio) {
        action = .edit(audio)
    }
}
