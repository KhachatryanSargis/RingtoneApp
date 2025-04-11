//
//  SampleBuffer.swift
//  RingtoneEditScreen
//
//  Created by Sargis Khachatryan on 09.04.25.
//

import Foundation

public final class SampleBuffer: Sendable {
    let samples: [Float]
    let sampleRate: Double
    
    /// Initialize the buffer with samples
    public init(samples: [Float], sampleRate: Double) {
        self.samples = samples
        self.sampleRate = sampleRate
    }
    
    /// Number of samples
    public var count: Int {
        samples.count
    }
}

extension SampleBuffer {
    /// Down-sample to fit in a given rect, assuming each bar is 2 points wide.
    func downSampleToFit(rect: CGRect, barWidth: CGFloat = 2) -> SampleBuffer {
        // Calculate how many bars can fit in the view
        let targetSampleCount = Int(rect.width / barWidth)
        
        // If we already have fewer samples than needed, no down-sampling required
        guard targetSampleCount < samples.count else {
            return self
        }
        
        let step = Double(samples.count) / Double(targetSampleCount)
        var downSampledSamples: [Float] = []
        
        for i in 0..<targetSampleCount {
            let start = Int(Double(i) * step)
            let end = Int(Double(i + 1) * step)
            let clampedEnd = min(end, samples.count)
            let segment = samples[start..<clampedEnd]
            
            let average = segment.reduce(0, +) / Float(segment.count)
            downSampledSamples.append(average)
        }
        
        return SampleBuffer(samples: downSampledSamples, sampleRate: sampleRate)
    }
}
