//
//  RingtoneDiscoverViewModel.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 22.02.25.
//

import Combine

public protocol RingtoneDiscoverViewModelFactory {
    func makeRingtoneDiscoverViewModel() -> RingtoneDiscoverViewModel
}

public enum RingtoneDiscoverViewModelAction {
    case export(RingtoneAudio)
    case edit(RingtoneAudio)
}

public final class RingtoneDiscoverViewModel {
    // MARK: - Properties
    @Published public private(set) var action: RingtoneDiscoverViewModelAction?
    @Published public private(set) var categories: [RingtoneCategory] = []
    @Published public private(set) var audios: [RingtoneAudio] = []
    
    public let audioFavoriteStatusChangeResponder: RingtoneAudioFavoriteStatusChangeResponder
    private let audioPlayer: IRingtoneAudioPlayer
    private var cancellables: Set<AnyCancellable> = []
    private var audioPlayerCancellable: AnyCancellable? {
        didSet {
            oldValue?.cancel()
        }
    }
    private let categoreisRepository: IRingtoneCategoriesRepository
    private let audioRepository: IRingtoneAudioRepository
    
    // MARK: - Methods
    public init(
        categoreisRepository: IRingtoneCategoriesRepository,
        audioRepository: IRingtoneAudioRepository,
        audiofavoriteStatusChangeResponder: RingtoneAudioFavoriteStatusChangeResponder,
        audioPlayer: IRingtoneAudioPlayer
    ) {
        self.categoreisRepository = categoreisRepository
        self.audioRepository = audioRepository
        self.audioFavoriteStatusChangeResponder = audiofavoriteStatusChangeResponder
        self.audioPlayer = audioPlayer
        
        getCategories()
        observeFavoriteAudios()
        observeAudioPlayerStatus()
    }
    
    private func getCategories() {
        categoreisRepository.getCategories()
            .sink { completion in
                guard case .failure(let error) = completion else { return }
                print(error)
            } receiveValue: { [weak self] categories in
                guard let self = self else { return }
                self.categories = categories
            }
            .store(in: &cancellables)
    }
    
    private func getRingtoneAudiosInCategory(_ category: RingtoneCategory) {
        audioRepository.getRingtoneAudiosInCategory(category)
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

// MARK: - Sync Favorite Audios
extension RingtoneDiscoverViewModel {
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

// MARK: - RingtoneDiscoverCategorySelectionResponder
extension RingtoneDiscoverViewModel: RingtoneDiscoverCategorySelectionResponder {
    public func selectCategory(_ category: RingtoneCategory) {
        getRingtoneAudiosInCategory(category)
    }
}

// MARK: - RingtoneAudioPlaybackStatusChangeResponder
extension RingtoneDiscoverViewModel: RingtoneAudioPlaybackStatusChangeResponder {
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
                case .failedToInitialize(let error):
                    print("failedToInitialize", error)
                    self.audios = self.audios.map { $0.paused() }
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - RingtoneAudioExportResponder
extension RingtoneDiscoverViewModel: RingtoneAudioExportResponder {
    public func exportRingtoneAudio(_ audio: RingtoneAudio) {
        action = .export(audio)
    }
}

// MARK: - RingtoneAudioEditResponder
extension RingtoneDiscoverViewModel: RingtoneAudioEditResponder {
    public func ringtoneAudioEdit(_ audio: RingtoneAudio) {
        action = .edit(audio)
    }
}
