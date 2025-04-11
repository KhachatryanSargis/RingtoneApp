//
//  AVAudio+FloatData.swift
//  RingtoneEditScreen
//
//  Created by Sargis Khachatryan on 09.04.25.
//

import Accelerate
import AVFoundation

extension AVAudioFile {
    func downsample(targetSampleCount: Int) -> SampleBuffer {
        let format = processingFormat
        let frameCount = Int(length)
        let channelCount = Int(format.channelCount)
        
        let samplesPerBucket = max(frameCount / targetSampleCount, 1)
        let readBufferSize = 4096
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(readBufferSize))!
        
        framePosition = 0
        
        var bucketMaxValues = [Float]()
        var currentBucket: [Float] = []
        var framesRead = 0
        
        while framePosition < length {
            do {
                try read(into: buffer, frameCount: AVAudioFrameCount(readBufferSize))
            } catch {
                print("Read error: \(error)")
                break
            }
            
            guard let channelData = buffer.floatChannelData else { break }
            let frameLength = Int(buffer.frameLength)
            
            for frame in 0..<frameLength {
                let monoSample: Float
                if channelCount == 2 {
                    // Mix stereo to mono
                    monoSample = (channelData[0][frame] + channelData[1][frame]) / 2.0
                } else {
                    monoSample = channelData[0][frame]
                }
                
                currentBucket.append(abs(monoSample))
                framesRead += 1
                
                if currentBucket.count >= samplesPerBucket {
                    let peak = currentBucket.max() ?? 0
                    bucketMaxValues.append(peak)
                    currentBucket.removeAll()
                }
            }
        }
        
        // Handle any remaining samples
        if !currentBucket.isEmpty {
            let peak = currentBucket.max() ?? 0
            bucketMaxValues.append(peak)
        }
        
        return SampleBuffer(samples: bucketMaxValues, sampleRate: format.sampleRate)
    }
}

extension AVAudioPCMBuffer {
    /// Returns audio data as an `Array` of `Float` Arrays.
    ///
    /// If stereo:
    /// - `floatChannelData?[0]` will contain an Array of left channel samples as `Float`
    /// - `floatChannelData?[1]` will contains an Array of right channel samples as `Float`
    func toFloatChannelData() -> [[Float]]? {
        // Do we have PCM channel data?
        guard let pcmFloatChannelData = floatChannelData else {
            return nil
        }
        
        let channelCount = Int(format.channelCount)
        let frameLength = Int(self.frameLength)
        let stride = self.stride
        
        // Preallocate our Array so we're not constantly thrashing while resizing as we append.
        let zeroes: [Float] = Array(repeating: 0, count: frameLength)
        var result = Array(repeating: zeroes, count: channelCount)
        
        // Loop across our channels...
        for channel in 0 ..< channelCount {
            // Make sure we go through all of the frames...
            for sampleIndex in 0 ..< frameLength {
                result[channel][sampleIndex] = pcmFloatChannelData[channel][sampleIndex * stride]
            }
        }
        
        return result
    }
}

extension AVAudioFile {
    /// converts to a 32 bit PCM buffer
    func toAVAudioPCMBuffer() -> AVAudioPCMBuffer? {
        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: processingFormat,
            frameCapacity: AVAudioFrameCount(length)
        ) else { return nil }
        
        do {
            framePosition = 0
            try read(into: buffer)
            print("Created buffer with format")
            
        } catch let error as NSError {
            print("Cannot read into buffer " + error.localizedDescription)
        }
        
        return buffer
    }
    
    /// converts to Swift friendly Float array
    public func floatChannelData() -> [[Float]]? {
        guard let pcmBuffer = toAVAudioPCMBuffer(),
              let data = pcmBuffer.toFloatChannelData() else { return nil }
        return data
    }
}
