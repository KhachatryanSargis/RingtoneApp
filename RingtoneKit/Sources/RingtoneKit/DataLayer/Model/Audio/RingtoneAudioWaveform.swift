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
    
    public func time(at offset: Int) -> TimeInterval {
        let clampedOffset = max(0, min(offset, samples.count))
        return startTimeInOriginal + (TimeInterval(clampedOffset) / TimeInterval(samples.count)) * duration
    }
    
    public func offset(at time: TimeInterval) -> Int {
        guard duration > 0 else { return 0 }
        let normalizedTime = (time - startTimeInOriginal) / duration
        return Int((normalizedTime * Double(samples.count)).rounded())
    }
    
    public func duration(from startIndex: Int, to endIndex: Int) -> TimeInterval {
        let clampedStart = max(0, min(startIndex, samples.count))
        let clampedEnd = max(0, min(endIndex, samples.count))
        let delta = max(0, clampedEnd - clampedStart)
        return (TimeInterval(delta) / TimeInterval(samples.count)) * duration
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
