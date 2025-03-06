//
//  RingtoneAudioRepository.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 27.02.25.
//

import Combine

public final class RingtoneAudioRepository: IRingtoneAudioRepository {
    // MARK: - Properties
    private let store: IRingtoneAudioStore
    
    public func addRingtoneAudios(_ audios: [RingtoneAudio]) -> AnyPublisher<[RingtoneAudio], RingtoneAudioRepositoryError> {
        store.addRingtoneAudios(audios)
            .mapError { .storeError($0) }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Methods
    public init(store: IRingtoneAudioStore) {
        self.store = store
    }
    
    public func getRingtoneAudiosInCategory(_ category: RingtoneCategory) -> AnyPublisher<[RingtoneAudio], RingtoneAudioRepositoryError> {
        store.getRingtoneAudiosInCategory(category)
            .mapError { .storeError($0) }
            .eraseToAnyPublisher()
    }
    
    public func getFavoriteRingtoneAudios() -> AnyPublisher<[RingtoneAudio], RingtoneAudioRepositoryError> {
        store.getFavoriteRingtoneAudios()
            .mapError { .storeError($0) }
            .eraseToAnyPublisher()
    }
    
    public func getCreatedRingtoneAudios() -> AnyPublisher<[RingtoneAudio], RingtoneAudioRepositoryError> {
        store.getCreatedRingtoneAudios()
            .mapError { .storeError($0) }
            .eraseToAnyPublisher()
    }
    
    public func toggleRingtoneAudioFavoriteStatus(_ audio: RingtoneAudio) -> AnyPublisher<RingtoneAudio, RingtoneAudioRepositoryError> {
        store.toggleRingtoneAudioFavoriteStatus(audio)
            .mapError { .storeError($0) }
            .eraseToAnyPublisher()
    }
}
