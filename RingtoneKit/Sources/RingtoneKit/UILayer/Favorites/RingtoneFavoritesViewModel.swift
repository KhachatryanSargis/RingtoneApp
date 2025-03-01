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
    public var audiosPublisher: AnyPublisher<[RingtoneAudio], Never> {
        $audios.eraseToAnyPublisher()
    }
    
    private var cancellables: Set<AnyCancellable> = []
    private let audioRepository: IRingtoneAudioRepository
    
    // MARK: - Methods
    public init(audioRepository: IRingtoneAudioRepository) {
        self.audioRepository = audioRepository
        
        getFavoriteAudios()
    }
    
    private func getFavoriteAudios() {
        audioRepository.getFavoriteRingtoneAudios()
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

// MARK: - RingtoneAudioPlaybackStatusChangeResponder
extension RingtoneFavoritesViewModel: RingtoneAudioPlaybackStatusChangeResponder {
    public func ringtoneAudioPlaybackStatusChange(_ audio: RingtoneAudio) {
        print("ringtoneAudioPlaybackStatusChange")
    }
}

// MARK: - RingtoneAudioFavoriteStatusChangeResponder
extension RingtoneFavoritesViewModel: RingtoneAudioFavoriteStatusChangeResponder {
    public func changeAudioFavoriteStatus(_ audio: RingtoneAudio) {
        audioRepository.toggleRingtoneAudioFavoriteStatus(audio)
            .sink { completion in
                guard case .failure(let error) = completion else { return }
                
                print(error)
            } receiveValue: { [weak self] audio in
                guard let self = self else { return }
                
                if audio.isFavorite {
                    guard self.audios.firstIndex(where: { audio.id == $0.id }) == nil
                    else { return }
                    
                    self.audios.append(audio)
                } else {
                    guard let index = self.audios.firstIndex(where: { audio.id == $0.id })
                    else { return }
                    
                    self.audios.remove(at: index)
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - RingtoneAudioExportResponder
extension RingtoneFavoritesViewModel: RingtoneAudioExportResponder {
    public func exportRingtoneAudio(_ audio: RingtoneAudio) {
        print("exportRingtoneAudio")
    }
}

// MARK: - RingtoneAudioEditResponder
extension RingtoneFavoritesViewModel: RingtoneAudioEditResponder {
    public func ringtoneAudioEdit(_ audio: RingtoneAudio) {
        print("ringtoneAudioEdit")
    }
}
