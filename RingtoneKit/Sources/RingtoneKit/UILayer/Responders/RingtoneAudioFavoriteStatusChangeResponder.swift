//
//  RingtoneAudioFavoriteStatusChangeResponder.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 28.02.25.
//

import Combine

public protocol RingtoneAudioFavoriteStatusChangeResponder {
    var audiosPublisher: AnyPublisher<[RingtoneAudio], Never> { get }
    func changeAudioFavoriteStatus(_ audio: RingtoneAudio)
}
