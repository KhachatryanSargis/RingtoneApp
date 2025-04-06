//
//  File.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 02.03.25.
//

import Combine

public protocol IRingtoneAudioPlayer: IRingtoneAudioPlayerProgressPublisher, IRingtoneAudioPlayerStatusPublisher {
    // MARK: - Properties
    var currentAudioID: String? { get }
    var isPlaying: Bool { get }
    
    // MARK: - Methods
    func play(_ audio: RingtoneAudio)
    func pause()
}
