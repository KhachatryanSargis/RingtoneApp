//
//  RingtoneDiscoverAudiosMediator.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 25.03.25.
//

import Combine

public protocol RingtoneDiscoverAudiosMediator {
    // MARK: - Properties
    var discoverAudiosPublisher: AnyPublisher<[RingtoneAudio], Never> { get }
    
    // MARK: - Methods
    // Selection
    func enableDiscoverAudiosSelection()
    func disableDiscoverAudiosSelection()
    func toggleDiscoverAudioSelection(_ audio: RingtoneAudio)
    func selectAllDiscoverAudios()
    func deselectAllDiscoverAudios()
    // Category
    func selectCategory(_ category: RingtoneCategory)
    // Favorite
    func changeAudioFavoriteStatus(_ audio: RingtoneAudio)
}
