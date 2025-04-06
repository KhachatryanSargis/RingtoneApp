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

public final class RingtoneDiscoverViewModel {
    // MARK: - Properties
    @Published public private(set) var action: RingtoneDiscoverViewModelAction?
    @Published public private(set) var categories: [RingtoneCategory] = []
    @Published public private(set) var audios: [RingtoneAudio] = []
    
    private var cancellables: Set<AnyCancellable> = []
    
    private let discoverAudiosMediator: RingtoneDiscoverAudiosMediator
    private let categoreisRepository: IRingtoneCategoriesRepository
    private let audioPlayer: IRingtoneAudioPlayer
    
    // MARK: - Methods
    public init(
        audioPlayer: IRingtoneAudioPlayer,
        discoverAudiosMediator: RingtoneDiscoverAudiosMediator,
        categoreisRepository: IRingtoneCategoriesRepository
    ) {
        self.audioPlayer = audioPlayer
        self.discoverAudiosMediator = discoverAudiosMediator
        self.categoreisRepository = categoreisRepository
        
        getCategories()
        observeDiscoverAudios()
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
    
    private func observeDiscoverAudios() {
        discoverAudiosMediator.discoverAudiosPublisher
            .sink { [weak self] discoverAudios in
                guard let self = self else { return }
                
                self.audios = discoverAudios
            }
            .store(in: &cancellables)
    }
}

// MARK: - Favorite
extension RingtoneDiscoverViewModel: RingtoneAudioFavoriteStatusChangeResponder {
    public func changeAudioFavoriteStatus(_ audio: RingtoneAudio) {
        discoverAudiosMediator.changeAudioFavoriteStatus(audio)
    }
}

// MARK: - Edit
extension RingtoneDiscoverViewModel: RingtoneAudioEditResponder {
    public func editRingtoneAudio(_ audio: RingtoneAudio) {
        action = .edit(audio)
    }
}

// MARK: - Export
extension RingtoneDiscoverViewModel: RingtoneAudioExportResponder {
    public func exportRingtoneAudio(_ audio: RingtoneAudio) {
        action = .export(audio)
    }
}

// MARK: - Category
extension RingtoneDiscoverViewModel: RingtoneAudioCategorySelectionResponder {
    public func selectCategory(_ category: RingtoneCategory) {
        discoverAudiosMediator.selectCategory(category)
    }
}

// MARK: - Playback
extension RingtoneDiscoverViewModel: RingtoneAudioPlaybackStatusChangeResponder {
    public func changeRingtoneAudioPlaybackStatus(_ audio: RingtoneAudio) {
        if audio.isPlaying {
            audioPlayer.pause()
        } else {
            audioPlayer.play(audio)
        }
    }
}
