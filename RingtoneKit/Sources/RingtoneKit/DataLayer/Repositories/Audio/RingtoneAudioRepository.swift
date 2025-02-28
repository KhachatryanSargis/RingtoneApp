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
    
    // MARK: - Methods
    public init(store: IRingtoneAudioStore) {
        self.store = store
    }
    
    public func getRingtoneAudiosInCategory(_ category: RingtoneCategory) -> AnyPublisher<[RingtoneAudio], RingtoneAudioRepositoryError> {
        store.getRingtoneAudiosInCategory(category)
            .mapError { .store($0) }
            .eraseToAnyPublisher()
    }
    
    public func getFavoriteRingtoneAudios() -> AnyPublisher<[RingtoneAudio], RingtoneAudioRepositoryError> {
        fatalError("getFavoriteRingtoneAudios not implemented")
    }
    
    public func getCreatedRingtoneAudios() -> AnyPublisher<[RingtoneAudio], RingtoneAudioRepositoryError> {
        fatalError("getCreatedRingtoneAudios not implemented")
    }
    
    public func toggleRingtoneAudioFavoriteStatus(_ audio: RingtoneAudio) -> AnyPublisher<RingtoneAudio, RingtoneAudioRepositoryError> {
        store.toggleRingtoneAudioFavoriteStatus(audio)
            .mapError { .store($0) }
            .eraseToAnyPublisher()
    }
}
