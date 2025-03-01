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
    @Published public private(set) var categories: [RingtoneCategory] = []
    @Published public private(set) var audios: [RingtoneAudio] = []
    
    public let audioFavoriteStatusChangeResponder: RingtoneAudioFavoriteStatusChangeResponder
    private var cancellables: Set<AnyCancellable> = []
    private let categoreisRepository: IRingtoneCategoriesRepository
    private let audioRepository: IRingtoneAudioRepository
    
    // MARK: - Methods
    public init(
        categoreisRepository: IRingtoneCategoriesRepository,
        audioRepository: IRingtoneAudioRepository,
        audiofavoriteStatusChangeResponder: RingtoneAudioFavoriteStatusChangeResponder
    ) {
        self.categoreisRepository = categoreisRepository
        self.audioRepository = audioRepository
        self.audioFavoriteStatusChangeResponder = audiofavoriteStatusChangeResponder
        
        getCategories()
        observeFavoriteAudios()
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
                        guard audio.isFavorite else { continue }
                        audios[index] = audio.likeToggled()
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
        print("ringtoneAudioPlaybackStatusChange")
    }
}

// MARK: - RingtoneAudioExportResponder
extension RingtoneDiscoverViewModel: RingtoneAudioExportResponder {
    public func exportRingtoneAudio(_ audio: RingtoneAudio) {
        print("exportRingtoneAudio")
    }
}

// MARK: - RingtoneAudioEditResponder
extension RingtoneDiscoverViewModel: RingtoneAudioEditResponder {
    public func ringtoneAudioEdit(_ audio: RingtoneAudio) {
        print("ringtoneAudioEdit")
    }
}
