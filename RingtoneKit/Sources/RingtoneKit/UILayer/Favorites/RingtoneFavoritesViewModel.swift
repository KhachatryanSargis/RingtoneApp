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
    private let audioPlayer: IRingtoneAudioPlayer
    
    // MARK: - Methods
    public init(
        audioRepository: IRingtoneAudioRepository,
        audioPlayer: IRingtoneAudioPlayer
    ) {
        self.audioRepository = audioRepository
        self.audioPlayer = audioPlayer
        
        getFavoriteAudios()
        observeAudioPlayerStatus()
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
