//
//  RingtoneAudioImportResponder.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 04.03.25.
//

import Combine

public protocol RingtoneAudioImportResponder {
    var audiosPublisher: AnyPublisher<[RingtoneAudio], Never> { get }
}
