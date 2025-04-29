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

// MARK: - Fade In
extension RingtoneAudioWaveform {
    public func fadeIn(range: (startPosition: Double, endPosition: Double), position: Double) -> RingtoneAudioWaveform {
        let clampedStart = max(0.0, min(1.0, range.startPosition))
        let clampedEnd = max(0.0, min(1.0, range.endPosition))
        let clampedPosition = max(0.0, min(1.0, position))
        
        guard clampedEnd > clampedStart else { return self }
        
        let fadeEndPosition = clampedStart + (clampedEnd - clampedStart) * clampedPosition
        
        let totalSamples = samples.count
        let startIndex = Int(Double(totalSamples) * clampedStart)
        let endIndex = Int(Double(totalSamples) * fadeEndPosition)
        
        var newSamples = samples
        
        for i in startIndex..<endIndex {
            let progress = Double(i - startIndex) / Double(endIndex - startIndex)
            let gain = progress
            newSamples[i] *= Float(gain)
        }
        
        return RingtoneAudioWaveform(
            samples: newSamples,
            startTimeInOriginal: startTimeInOriginal,
            endTimeInOriginal: endTimeInOriginal
        )
    }
}

// MARK: - Fade Out
extension RingtoneAudioWaveform {
    public func fadeOut(range: (startPosition: Double, endPosition: Double), position: Double) -> RingtoneAudioWaveform {
        let clampedStart = max(0.0, min(1.0, range.startPosition))
        let clampedEnd = max(0.0, min(1.0, range.endPosition))
        let clampedPosition = max(0.0, min(1.0, position))
        
        guard clampedEnd > clampedStart else { return self }
        
        let fadeEndPosition = clampedEnd
        let fadeStartPosition = clampedEnd - (clampedEnd - clampedStart) * clampedPosition
        
        let totalSamples = samples.count
        let startIndex = Int(Double(totalSamples) * fadeStartPosition)
        let endIndex = Int(Double(totalSamples) * fadeEndPosition)
        
        var newSamples = samples
        
        for i in startIndex..<endIndex {
            let progress = Double(i - startIndex) / Double(endIndex - startIndex)
            let gain = 1.0 - progress
            newSamples[i] *= Float(gain)
        }
        
        return RingtoneAudioWaveform(
            samples: newSamples,
            startTimeInOriginal: startTimeInOriginal,
            endTimeInOriginal: endTimeInOriginal
        )
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
