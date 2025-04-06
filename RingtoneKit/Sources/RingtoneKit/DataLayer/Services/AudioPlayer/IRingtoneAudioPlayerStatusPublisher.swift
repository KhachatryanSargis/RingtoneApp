//
//  IRingtoneAudioPlayerStatusPublisher.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 06.04.25.
//

import Combine

public protocol IRingtoneAudioPlayerStatusPublisher {
    var statusPublisher: AnyPublisher<RingtoneAudioPlayerStatus, Never> { get }
}
