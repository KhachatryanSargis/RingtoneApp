//
//  File.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 16.04.25.
//

import AVFoundation
import Accelerate

final class ZoomWaveformOperation: AsyncOperation, @unchecked Sendable {
    // MARK: - Properties
    private var channelCount: Int = 2
    private var sampleRate: Double = 44100
    private var waveformSamples: [Float] = []
    
    private var reader: AVAssetReader!
    
    private let audio: RingtoneAudio
    private let start: TimeInterval
    private let end: TimeInterval
    private let completion: ((Result<RingtoneAudioWaveform, RingtoneDataEditorError>) -> Void)?
    
    // MARK: - Init
    init(
        audio: RingtoneAudio,
        start: TimeInterval,
        end: TimeInterval,
        completion: ((Result<RingtoneAudioWaveform, RingtoneDataEditorError>) -> Void)?
    ) {
        self.audio = audio
        self.start = start
        self.end = end
        self.completion = completion
    }
    
    // MARK: - Execution
    override func main() {
        let asset = AVURLAsset(url: audio.url)
        
        do {
            reader = try AVAssetReader(asset: asset)
            
            let startTime = CMTime(seconds: start, preferredTimescale: asset.duration.timescale)
            let endTime = CMTime(seconds: end, preferredTimescale: asset.duration.timescale)
            let timeRange = CMTimeRangeFromTimeToTime(start: startTime, end: endTime)
            
            reader.timeRange = timeRange
        } catch {
            finish(with: .failedToCreateReader(error))
            return
        }
        
        asset.loadTracks(withMediaType: .audio) { [weak self] tracks, error in
            guard let self else { return }
            
            if let error = error {
                self.finish(with: .loadAudioTrackError(error))
                return
            }
            
            guard let track = tracks?.first else {
                self.finish(with: .missingAudioTrack)
                return
            }
            
            self.setupReader(for: track, asset: asset)
        }
    }
    
    private func setupReader(for track: AVAssetTrack, asset: AVAsset) {
        let formatDescriptions = track.formatDescriptions as! [CMAudioFormatDescription]
        for item in formatDescriptions {
            guard let fmtDesc = CMAudioFormatDescriptionGetStreamBasicDescription(item)
            else {
                finish(with: .unexpected)
                return
            }
            
            channelCount = Int(fmtDesc.pointee.mChannelsPerFrame)
            sampleRate = fmtDesc.pointee.mSampleRate
        }
        
        let readerSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: sampleRate,
            AVNumberOfChannelsKey: channelCount,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsNonInterleaved: false,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false
        ]
        
        let readerOutput = AVAssetReaderTrackOutput(track: track, outputSettings: readerSettings)
        readerOutput.alwaysCopiesSampleData = false
        
        guard reader.canAdd(readerOutput)
        else {
            finish(with: .failedToAddReaderOutput)
            return
        }
        reader.add(readerOutput)
        
        processSamples(
            track: track,
            readerOutput: readerOutput,
            channelCount: channelCount
        )
    }
    
    private func processSamples(track: AVAssetTrack, readerOutput: AVAssetReaderTrackOutput, channelCount: Int) {
        let duration = end - start
        let totalFramesEstimate = Int(sampleRate * duration)
        let targetWaveformLength = 10_000
        let downsampleFactor = max(1, totalFramesEstimate / targetWaveformLength)
        
        reader.startReading()
        
        let readerOutput = self.reader.outputs[0]
        
        var readerOutputHasData: Bool = true
        
        while readerOutputHasData {
            guard let sampleBuffer = readerOutput.copyNextSampleBuffer(),
                  let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer)
            else {
                switch reader.status {
                case .completed:
                    let waveform = normalizeWaveformSamples()
                    finish(with: waveform)
                default:
                    if let error = reader.error {
                        finish(with: .reader(error))
                    } else {
                        finish(with: .unexpected)
                    }
                }
                
                readerOutputHasData = false
                break
            }
            
            self.processBlockBuffer(
                blockBuffer,
                channelCount: channelCount,
                downsampleFactor: downsampleFactor
            )
        }
    }
    
    private func processBlockBuffer(_ blockBuffer: CMBlockBuffer, channelCount: Int, downsampleFactor: Int) {
        var length = 0
        var dataPointer: UnsafeMutablePointer<Int8>?
        
        guard CMBlockBufferGetDataPointer(
            blockBuffer,
            atOffset: 0,
            lengthAtOffsetOut: nil,
            totalLengthOut: &length,
            dataPointerOut: &dataPointer
        ) == noErr, let dataPointer else { return }
        
        let sampleCount = length / MemoryLayout<Int16>.size
        let frameCount = sampleCount / channelCount
        
        // Convert Int16 PCM to normalized float [-1, 1]
        var floatSamples = [Float](repeating: 0, count: sampleCount)
        dataPointer.withMemoryRebound(to: Int16.self, capacity: sampleCount) { int16Pointer in
            vDSP_vflt16(int16Pointer, 1, &floatSamples, 1, vDSP_Length(sampleCount))
        }
        var divisor = Float(Int16.max)
        vDSP_vsdiv(floatSamples, 1, &divisor, &floatSamples, 1, vDSP_Length(sampleCount))
        
        // Mix interleaved samples directly to mono by averaging frames
        var monoSamples = [Float](repeating: 0, count: frameCount)
        vDSP_desamp(
            floatSamples,
            channelCount,
            [Float](repeating: 1 / Float(channelCount), count: channelCount),
            &monoSamples,
            vDSP_Length(frameCount),
            vDSP_Length(channelCount)
        )
        
        // Take absolute value for waveform
        var absSamples = [Float](repeating: 0, count: frameCount)
        vDSP_vabs(monoSamples, 1, &absSamples, 1, vDSP_Length(frameCount))
        
        // Downsample to max of 10_000
        let downsampledLength = absSamples.count / downsampleFactor
        var downsampled = [Float](repeating: 0, count: downsampledLength)
        
        vDSP_desamp(
            absSamples,
            downsampleFactor,
            [Float](repeating: 1.0 / Float(downsampleFactor), count: downsampleFactor),
            &downsampled,
            vDSP_Length(downsampledLength),
            vDSP_Length(downsampleFactor)
        )
        
        waveformSamples.append(contentsOf: downsampled)
    }
    
    private func normalizeWaveformSamples() -> RingtoneAudioWaveform {
        if let maxSample = waveformSamples.max(), maxSample > 0 {
            var maxValue = maxSample
            var normalizedSamples = [Float](repeating: 0, count: waveformSamples.count)
            
            vDSP_vsdiv(
                waveformSamples,
                1,
                &maxValue,
                &normalizedSamples,
                1,
                vDSP_Length(waveformSamples.count)
            )
            
            waveformSamples = normalizedSamples
        }
        
        return RingtoneAudioWaveform(
            samples: waveformSamples,
            startTimeInOriginal: 0,
            endTimeInOriginal: end - start
        )
    }
    
    private func finish(with waveform: RingtoneAudioWaveform) {
        self.completion?(.success(waveform))
        self.state = .finished
    }
    
    private func finish(with error: RingtoneDataEditorError) {
        self.completion?(.failure(error))
        self.state = .finished
    }
}
