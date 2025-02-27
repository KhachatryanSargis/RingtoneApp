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
    }
    
    public func getFavoriteRingtoneAudios() -> AnyPublisher<[RingtoneAudio], RingtoneAudioRepositoryError> {
        fatalError("getFavoriteRingtoneAudios not implemented")
    }
    
    public func getCreatedRingtoneAudios() -> AnyPublisher<[RingtoneAudio], RingtoneAudioRepositoryError> {
        fatalError("getCreatedRingtoneAudios not implemented")
    }
    
    public func addRingtoneAudioToFavorites(_ audio: RingtoneAudio) -> AnyPublisher<RingtoneAudio, RingtoneAudioRepositoryError> {
        fatalError("addRingtoneAudioToFavorites not implemented")
    }
    
    public func removeRingtoneAudioFromFavorites(_ audio: RingtoneAudio) -> AnyPublisher<RingtoneAudio, RingtoneAudioRepositoryError> {
        fatalError("removeRingtoneAudioFromFavorites not implemented")
    }
}
