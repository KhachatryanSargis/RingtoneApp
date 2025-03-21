//
//  RingtoneAudioStore.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 27.02.25.
//

import Combine

public final class RingtoneAudioStore: IRingtoneAudioStore {
    // MARK: - Methods
    public init() {}
    
    public func addRingtoneAudios(_ audios: [RingtoneAudio]) -> AnyPublisher<[RingtoneAudio], RingtoneAudioStoreError> {
        let items = audios.map { RingtoneAudioStoreItem.constrcutFromAudio($0) }
        self.items.append(contentsOf: items)
        return Just(audios)
            .setFailureType(to: RingtoneAudioStoreError.self)
            .eraseToAnyPublisher()
    }
    
    public func deleteRingtoneAudios(_ audios: [RingtoneAudio]) -> AnyPublisher<[RingtoneAudio], RingtoneAudioStoreError> {
        var currentItems = self.items
        
        for audio in audios {
            guard let index = items.firstIndex(where: { audio.id == $0.id })
            else { continue }
            
            currentItems.remove(at: index)
        }
        
        self.items = currentItems
        
        return Just(audios)
            .setFailureType(to: RingtoneAudioStoreError.self)
            .eraseToAnyPublisher()
    }
    
    public func getRingtoneAudiosInCategory(_ category: RingtoneCategory) -> AnyPublisher<[RingtoneAudio], RingtoneAudioStoreError> {
        let filteredAudios = items.filter { $0.categoryID == category.displayName }.map { $0.convertToAudio() }
        return Just(filteredAudios)
            .setFailureType(to: RingtoneAudioStoreError.self)
            .eraseToAnyPublisher()
    }
    
    public func getFavoriteRingtoneAudios() -> AnyPublisher<[RingtoneAudio], RingtoneAudioStoreError> {
        let filteredAudios = items.filter { $0.isFavorite }.map { $0.convertToAudio() }
        return Just(filteredAudios)
            .setFailureType(to: RingtoneAudioStoreError.self)
            .eraseToAnyPublisher()
    }
    
    public func getCreatedRingtoneAudios() -> AnyPublisher<[RingtoneAudio], RingtoneAudioStoreError> {
        let filteredAudios = items.filter { $0.isCreated }.map { $0.convertToAudio() }
        return Just(filteredAudios)
            .setFailureType(to: RingtoneAudioStoreError.self)
            .eraseToAnyPublisher()
    }
    
    public func toggleRingtoneAudioFavoriteStatus(_ audio: RingtoneAudio) -> AnyPublisher<RingtoneAudio, RingtoneAudioStoreError> {
        guard let audioIndex = items.firstIndex(where: { audio.id == $0.id })
        else {
            return Fail<RingtoneAudio, RingtoneAudioStoreError>(
                error: .toggleRingtoneAudioFavoriteStatus
            )
            .eraseToAnyPublisher()
        }
        
        let updatedAudio = audio.isFavorite ? audio.unliked() : audio.liked()
        
        items[audioIndex] = .constrcutFromAudio(updatedAudio)
        
        return Just(updatedAudio)
            .setFailureType(to: RingtoneAudioStoreError.self)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Mock Ringtone Audios
    private var items: [RingtoneAudioStoreItem] = [
        // MARK: - Trending
        .init(title: "Ringtone 1 in Trending", description: "01:20 • 1.2 MB", categoryID: "Trending"),
        .init(title: "Ringtone 2 in Trending", description: "01:20 • 1.2 MB", categoryID: "Trending"),
        .init(title: "Ringtone 3 in Trending", description: "01:20 • 1.2 MB", categoryID: "Trending"),
        .init(title: "Ringtone 4 in Trending", description: "01:20 • 1.2 MB", categoryID: "Trending"),
        .init(title: "Ringtone 5 in Trending", description: "01:20 • 1.2 MB", categoryID: "Trending"),
        // MARK: - Hip Hop
        .init(title: "Ringtone 1 in Hip Hop", description: "01:10 • 1.1 MB", categoryID: "Hip Hop"),
        .init(title: "Ringtone 2 in Hip Hop", description: "01:10 • 1.1 MB", categoryID: "Hip Hop"),
        .init(title: "Ringtone 3 in Hip Hop", description: "01:10 • 1.1 MB", categoryID: "Hip Hop"),
        .init(title: "Ringtone 4 in Hip Hop", description: "01:10 • 1.1 MB", categoryID: "Hip Hop"),
        .init(title: "Ringtone 5 in Hip Hop", description: "01:10 • 1.1 MB", categoryID: "Hip Hop"),
        // MARK: - Jazz
        .init(title: "Ringtone 1 in Jazz", description: "00:40 • 0.8 MB", categoryID: "Jazz"),
        .init(title: "Ringtone 2 in Jazz", description: "00:40 • 0.8 MB", categoryID: "Jazz"),
        .init(title: "Ringtone 3 in Jazz", description: "00:40 • 0.8 MB", categoryID: "Jazz"),
        .init(title: "Ringtone 4 in Jazz", description: "00:40 • 0.8 MB", categoryID: "Jazz"),
        .init(title: "Ringtone 5 in Jazz", description: "00:40 • 0.8 MB", categoryID: "Jazz"),
        // MARK: - Electro
        .init(title: "Ringtone 1 in Electro", description: "02:20 • 2.3 MB", categoryID: "Electro"),
        .init(title: "Ringtone 2 in Electro", description: "02:20 • 2.3 MB", categoryID: "Electro"),
        .init(title: "Ringtone 3 in Electro", description: "02:20 • 2.3 MB", categoryID: "Electro"),
        .init(title: "Ringtone 4 in Electro", description: "02:20 • 2.3 MB", categoryID: "Electro"),
        .init(title: "Ringtone 5 in Electro", description: "02:20 • 2.3 MB", categoryID: "Electro"),
        // MARK: - Prank
        .init(title: "Ringtone 1 in Prank", description: "01:50 • 1.6 MB", categoryID: "Prank"),
        .init(title: "Ringtone 2 in Prank", description: "01:50 • 1.6 MB", categoryID: "Prank"),
        .init(title: "Ringtone 3 in Prank", description: "01:50 • 1.6 MB", categoryID: "Prank"),
        .init(title: "Ringtone 4 in Prank", description: "01:50 • 1.6 MB", categoryID: "Prank"),
        .init(title: "Ringtone 5 in Prank", description: "01:50 • 1.6 MB", categoryID: "Prank"),
        // MARK: - Meme
        .init(title: "Ringtone 1 in Meme", description: "01:00 • 1.0 MB", categoryID: "Meme"),
        .init(title: "Ringtone 2 in Meme", description: "01:00 • 1.0 MB", categoryID: "Meme"),
        .init(title: "Ringtone 3 in Meme", description: "01:00 • 1.0 MB", categoryID: "Meme"),
        .init(title: "Ringtone 4 in Meme", description: "01:00 • 1.0 MB", categoryID: "Meme"),
        .init(title: "Ringtone 5 in Meme", description: "01:00 • 1.0 MB", categoryID: "Meme")
    ]
}
