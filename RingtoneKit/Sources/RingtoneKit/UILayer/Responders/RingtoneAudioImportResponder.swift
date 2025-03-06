//
//  RingtoneAudioImportResponder.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 04.03.25.
//

import Combine

public protocol RingtoneAudioImportResponder {
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    var audiosPublisher: AnyPublisher<[RingtoneAudio], Never> { get }
}
