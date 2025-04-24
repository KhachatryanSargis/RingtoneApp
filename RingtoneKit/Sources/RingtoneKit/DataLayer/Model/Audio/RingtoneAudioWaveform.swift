//
//  RingtoneAudioWaveform.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 11.04.25.
//

import Foundation

public struct RingtoneAudioWaveform: Sendable, Codable {
    // MARK: - Properties
    public var count: Int {
        samples.count
    }
    
    public var duration: TimeInterval {
        endTimeInOriginal - startTimeInOriginal
    }
    
    public let samples: [Float]
    public let startTimeInOriginal: TimeInterval
    public let endTimeInOriginal: TimeInterval
    
    // MARK: - Methods
    public init(
        samples: [Float],
        startTimeInOriginal: TimeInterval,
        endTimeInOriginal: TimeInterval
    ) {
        self.samples = samples
        self.startTimeInOriginal = startTimeInOriginal
        self.endTimeInOriginal = endTimeInOriginal
    }
}

extension RingtoneAudioWaveform {
    public static var empty: RingtoneAudioWaveform {
        return .init(
            samples: [],
            startTimeInOriginal: 0,
            endTimeInOriginal: 0
        )
    }
}
