//
//  IRingtoneAudioStore.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 27.02.25.
//

import Combine

public protocol IRingtoneAudioStore {
    func getRingtoneAudiosInCategory(_ category: RingtoneCategory) -> AnyPublisher<[RingtoneAudio], RingtoneAudioRepositoryError>
    func getFavoriteRingtoneAudios() -> AnyPublisher<[RingtoneAudio], RingtoneAudioRepositoryError>
    func getCreatedRingtoneAudios() -> AnyPublisher<[RingtoneAudio], RingtoneAudioRepositoryError>
    
    func addRingtoneAudioToFavorites(_ audio: RingtoneAudio) -> AnyPublisher<RingtoneAudio, RingtoneAudioRepositoryError>
    func removeRingtoneAudioFromFavorites(_ audio: RingtoneAudio) -> AnyPublisher<RingtoneAudio, RingtoneAudioRepositoryError>
}
