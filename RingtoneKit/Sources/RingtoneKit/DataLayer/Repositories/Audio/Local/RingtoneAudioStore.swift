//
//  RingtoneAudioStore.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 27.02.25.
//

import Combine

public final class RingtoneAudioStore: IRingtoneAudioStore {
    public func getRingtoneAudiosInCategory(_ category: RingtoneCategory) -> AnyPublisher<[RingtoneAudio], RingtoneAudioRepositoryError> {
        let filteredAudios = ringtoneAudios.filter { $0.categoryID == category.displayName }
        return Just(filteredAudios)
            .setFailureType(to: RingtoneAudioRepositoryError.self)
            .eraseToAnyPublisher()
    }
    
    public func getFavoriteRingtoneAudios() -> AnyPublisher<[RingtoneAudio], RingtoneAudioRepositoryError> {
        fatalError()
    }
    
    public func getCreatedRingtoneAudios() -> AnyPublisher<[RingtoneAudio], RingtoneAudioRepositoryError> {
        fatalError()
    }
    
    public func addRingtoneAudioToFavorites(_ audio: RingtoneAudio) -> AnyPublisher<RingtoneAudio, RingtoneAudioRepositoryError> {
        fatalError()
    }
    
    public func removeRingtoneAudioFromFavorites(_ audio: RingtoneAudio) -> AnyPublisher<RingtoneAudio, RingtoneAudioRepositoryError> {
        fatalError()
    }
}

fileprivate let ringtoneAudios: [RingtoneAudio] = [
    .init(title: "Ringtone 1 in Trending", categoryID: "Trending"),
    .init(title: "Ringtone 2 in Trending", categoryID: "Trending"),
    .init(title: "Ringtone 3 in Trending", categoryID: "Trending"),
    .init(title: "Ringtone 4 in Trending", categoryID: "Trending"),
    .init(title: "Ringtone 5 in Trending", categoryID: "Trending"),
    .init(title: "Ringtone 6 in Trending", categoryID: "Trending"),
    .init(title: "Ringtone 7 in Trending", categoryID: "Trending"),
    .init(title: "Ringtone 8 in Trending", categoryID: "Trending"),
    .init(title: "Ringtone 9 in Trending", categoryID: "Trending"),
    .init(title: "Ringtone 10 in Trending", categoryID: "Trending"),
    
        .init(title: "Ringtone 1 in Hip Hop", categoryID: "Hip Hop"),
    .init(title: "Ringtone 2 in Hip Hop", categoryID: "Hip Hop"),
    .init(title: "Ringtone 3 in Hip Hop", categoryID: "Hip Hop"),
    .init(title: "Ringtone 4 in Hip Hop", categoryID: "Hip Hop"),
    .init(title: "Ringtone 5 in Hip Hop", categoryID: "Hip Hop"),
    .init(title: "Ringtone 6 in Hip Hop", categoryID: "Hip Hop"),
    .init(title: "Ringtone 7 in Hip Hop", categoryID: "Hip Hop"),
    .init(title: "Ringtone 8 in Hip Hop", categoryID: "Hip Hop"),
    .init(title: "Ringtone 9 in Hip Hop", categoryID: "Hip Hop"),
    .init(title: "Ringtone 10 in Hip Hop", categoryID: "Hip Hop"),
    
        .init(title: "Ringtone 1 in Jazz", categoryID: "Jazz"),
    .init(title: "Ringtone 2 in Jazz", categoryID: "Jazz"),
    .init(title: "Ringtone 3 in Jazz", categoryID: "Jazz"),
    .init(title: "Ringtone 4 in Jazz", categoryID: "Jazz"),
    .init(title: "Ringtone 5 in Jazz", categoryID: "Jazz"),
    .init(title: "Ringtone 6 in Jazz", categoryID: "Jazz"),
    .init(title: "Ringtone 7 in Jazz", categoryID: "Jazz"),
    .init(title: "Ringtone 8 in Jazz", categoryID: "Jazz"),
    .init(title: "Ringtone 9 in Jazz", categoryID: "Jazz"),
    .init(title: "Ringtone 10 in Jazz", categoryID: "Jazz"),
    
        .init(title: "Ringtone 1 in Electro", categoryID: "Electro"),
    .init(title: "Ringtone 2 in Electro", categoryID: "Electro"),
    .init(title: "Ringtone 3 in Electro", categoryID: "Electro"),
    .init(title: "Ringtone 4 in Electro", categoryID: "Electro"),
    .init(title: "Ringtone 5 in Electro", categoryID: "Electro"),
    .init(title: "Ringtone 6 in Electro", categoryID: "Electro"),
    .init(title: "Ringtone 7 in Electro", categoryID: "Electro"),
    .init(title: "Ringtone 8 in Electro", categoryID: "Electro"),
    .init(title: "Ringtone 9 in Electro", categoryID: "Electro"),
    .init(title: "Ringtone 10 in Electro", categoryID: "Electro"),
    
        .init(title: "Ringtone 1 in Prank", categoryID: "Prank"),
    .init(title: "Ringtone 2 in Prank", categoryID: "Prank"),
    .init(title: "Ringtone 3 in Prank", categoryID: "Prank"),
    .init(title: "Ringtone 4 in Prank", categoryID: "Prank"),
    .init(title: "Ringtone 5 in Prank", categoryID: "Prank"),
    .init(title: "Ringtone 6 in Prank", categoryID: "Prank"),
    .init(title: "Ringtone 7 in Prank", categoryID: "Prank"),
    .init(title: "Ringtone 8 in Prank", categoryID: "Prank"),
    .init(title: "Ringtone 9 in Prank", categoryID: "Prank"),
    .init(title: "Ringtone 10 in Prank", categoryID: "Prank"),
    
        .init(title: "Ringtone 1 in Meme", categoryID: "Meme"),
    .init(title: "Ringtone 2 in Meme", categoryID: "Meme"),
    .init(title: "Ringtone 3 in Meme", categoryID: "Meme"),
    .init(title: "Ringtone 4 in Meme", categoryID: "Meme"),
    .init(title: "Ringtone 5 in Meme", categoryID: "Meme"),
    .init(title: "Ringtone 6 in Meme", categoryID: "Meme"),
    .init(title: "Ringtone 7 in Meme", categoryID: "Meme"),
    .init(title: "Ringtone 8 in Meme", categoryID: "Meme"),
    .init(title: "Ringtone 9 in Meme", categoryID: "Meme"),
    .init(title: "Ringtone 10 in Meme", categoryID: "Meme"),
]
