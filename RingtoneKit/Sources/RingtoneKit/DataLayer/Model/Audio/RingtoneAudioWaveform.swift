//
//  RingtoneAudioWaveform.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 11.04.25.
//

import Foundation

public struct RingtoneAudioWaveform: Sendable, Codable {
    public let samples: [Float]
    public let sampleRate: Double
    public let originalSampleCount: Int
    
    public init(
        samples: [Float],
        sampleRate: Double,
        originalSampleCount: Int
    ) {
        self.samples = samples
        self.sampleRate = sampleRate
        self.originalSampleCount = originalSampleCount
    }
    
    public var count: Int {
        samples.count
    }
    
    public var effectiveSampleRate: Double {
        return sampleRate * (Double(samples.count) / Double(originalSampleCount))
    }
    
    public func time(at offset: Int) -> TimeInterval {
        return TimeInterval(offset) / effectiveSampleRate
    }
    
    public func offset(at time: TimeInterval) -> Int {
        return Int(time * effectiveSampleRate)
    }
    
    public func duration(from startIndex: Int, to endIndex: Int) -> TimeInterval {
        let clampedStart = max(0, min(startIndex, samples.count))
        let clampedEnd = max(0, min(endIndex, samples.count))
        let delta = max(0, clampedEnd - clampedStart)
        return TimeInterval(delta) / effectiveSampleRate
    }
    
    public var duration: TimeInterval {
        return time(at: count)
    }
}

extension RingtoneAudioWaveform {
    public static var empty: RingtoneAudioWaveform {
        return .init(
            samples: [],
            sampleRate: 0,
            originalSampleCount: 0
        )
    }
}
