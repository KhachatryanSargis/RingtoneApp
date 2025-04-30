//
//  IRingtoneAudioPlayer.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 02.03.25.
//

import Foundation
import Combine

public protocol IRingtoneAudioPlayer: IRingtoneAudioPlayerProgressPublisher, IRingtoneAudioPlayerStatusPublisher {
    // MARK: - Properties
    var currentAudioID: String? { get }
    
    // MARK: - Methods
    func play(_ audio: RingtoneAudio)
    func play(_ audio: RingtoneAudio, range: (start: TimeInterval, end: TimeInterval))
    func pause()
    func stop()
}
