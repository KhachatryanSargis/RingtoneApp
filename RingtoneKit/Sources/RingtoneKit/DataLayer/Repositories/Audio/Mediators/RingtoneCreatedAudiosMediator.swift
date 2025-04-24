//
//  RingtoneCreatedAudiosMediator.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 25.03.25.
//

import Combine

public protocol RingtoneCreatedAudiosMediator {
    // MARK: - Properties
    var createdAudiosPublisher: AnyPublisher<[RingtoneAudio], Never> { get }
    
    // MARK: - Methods
    // Selection
    func enableCreatedAudiosSelection()
    func disableCreatedAudiosSelection()
    func toggleCreatedAudioSelection(_ audio: RingtoneAudio)
    func selectAllCreatedAudios()
    func deselectAllCreatedAudios()
    // Add
    func addRingtoneAudios(_ audios: [RingtoneAudio])
    // Delete
    func deleteRingtoneAudios(_ audios: [RingtoneAudio])
    // Favorite
    func changeAudioFavoriteStatus(_ audio: RingtoneAudio)
    // Save
    func saveRingtoneAudio(_ audio: RingtoneAudio)
}
