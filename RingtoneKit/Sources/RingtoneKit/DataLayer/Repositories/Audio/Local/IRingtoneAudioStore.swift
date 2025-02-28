//
//  IRingtoneAudioStore.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 27.02.25.
//

import Combine

public protocol IRingtoneAudioStore {
    func getRingtoneAudiosInCategory(_ category: RingtoneCategory) -> AnyPublisher<[RingtoneAudio], RingtoneAudioStoreError>
    func getFavoriteRingtoneAudios() -> AnyPublisher<[RingtoneAudio], RingtoneAudioStoreError>
    func getCreatedRingtoneAudios() -> AnyPublisher<[RingtoneAudio], RingtoneAudioStoreError>
    
    func toggleRingtoneAudioFavoriteStatus(_ audio: RingtoneAudio) -> AnyPublisher<RingtoneAudio, RingtoneAudioStoreError>
}
