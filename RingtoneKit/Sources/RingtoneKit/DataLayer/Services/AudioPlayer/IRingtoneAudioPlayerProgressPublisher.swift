//
//  IRingtoneAudioPlayerProgressPublisher.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 03.03.25.
//

import Foundation
import Combine

public protocol IRingtoneAudioPlayerProgressPublisher: NSObject {
    var progressPublisher: AnyPublisher<Float, Never> { get }
}
