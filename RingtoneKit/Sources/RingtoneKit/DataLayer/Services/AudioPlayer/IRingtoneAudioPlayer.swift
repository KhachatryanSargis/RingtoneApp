//
//  File.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 02.03.25.
//

import Combine

public protocol IRingtoneAudioPlayer {
    // MARK: - Properties
    var currentAudioID: String? { get }
    var statusPublisher: AnyPublisher<RingtoneAudioPlayerStatus, Never> { get }
    
    // MARK: - Methods
    func play(_ audio: RingtoneAudio)
    func pause()
}
