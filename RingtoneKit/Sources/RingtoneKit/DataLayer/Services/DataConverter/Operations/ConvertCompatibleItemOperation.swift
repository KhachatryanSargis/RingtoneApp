//
//  ConvertCompatibleItemOperation.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 16.03.25.
//

import AVFoundation
import Accelerate

final class ConvertCompatibleItemOperation: AsyncOperation, @unchecked Sendable {
    // MARK: - Properties
    private var channelCount: Int = 2
    private var sampleRate: Double = 44100
    private var waveformSamples: [Float] = []
    private var didFinishProcessing = false
    
    private let item: IRingtoneDataConverterCompatibleItem
    private let completion: ((Result<(url: URL, waveformURL: URL, duration: TimeInterval), RingtoneDataConverterError>) -> Void)?
    
    private var reader: AVAssetReader!
    private var writer: AVAssetWriter!
    
    // MARK: - Init
    init(item: IRingtoneDataConverterCompatibleItem,
         completion: ((Result<(url: URL, waveformURL: URL, duration: TimeInterval), RingtoneDataConverterError>) -> Void)?) {
        self.item = item
        self.completion = completion
    }
    
    // MARK: - Execution
    override func main() {
        let asset = AVURLAsset(url: item.url)
        
        do {
            reader = try AVAssetReader(asset: asset)
        } catch {
            finish(with: .failedToCreateReader(error))
            return
        }
        
        let outputURL = FileManager.default.ringtonesDirectory.appendingPathComponent(
            "\(item.id.uuidString).aiff"
        )
        
        do {
            writer = try AVAssetWriter(outputURL: outputURL, fileType: .aiff)
        } catch {
            finish(with: .failedToCreateWriter(error))
            return
        }
        
        asset.loadTracks(withMediaType: .audio) { [weak self] tracks, error in
            guard let self else { return }
            
            if let error = error {
                self.finish(with: .loadAudioTrackError(error))
                return
            }
            
            guard let track = tracks?.first else {
                self.finish(with: .unexpected)
                return
            }
            
            self.setupReaderWriter(for: track, asset: asset)
        }
    }
    
    private func setupReaderWriter(for track: AVAssetTrack, asset: AVAsset) {
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
        
        let readerSettings = AVAssetReader.settings(
            sampleRate: sampleRate,
            channelCount: channelCount
        )
        
        let readerOutput = AVAssetReaderTrackOutput(track: track, outputSettings: readerSettings)
        readerOutput.alwaysCopiesSampleData = false
        
        guard reader.canAdd(readerOutput)
        else {
            finish(with: .failedToAddReaderOutput)
            return
        }
        reader.add(readerOutput)
        
        let writerSettings = AVAssetWriter.settings(
            sampleRate: sampleRate,
            channelCount: channelCount
        )
        
        let writerInput = AVAssetWriterInput(mediaType: .audio, outputSettings: writerSettings)
        
        guard writer.canAdd(writerInput)
        else {
            finish(with: .failedToAddWriterInput)
            return
        }
        writer.add(writerInput)
        
        processSamples(
            track: track,
            writerInput: writerInput,
            readerOutput: readerOutput,
            channelCount: channelCount
        )
    }
    
    private func processSamples(
        track: AVAssetTrack,
        writerInput: AVAssetWriterInput,
        readerOutput: AVAssetReaderTrackOutput,
        channelCount: Int
    ) {
        let duration = CMTimeGetSeconds(track.timeRange.duration)
        let totalFramesEstimate = Int(sampleRate * duration)
        let targetWaveformLength = 10_000
        let downsampleFactor = max(1, totalFramesEstimate / targetWaveformLength)
        
        reader.startReading()
        writer.startWriting()
        writer.startSession(atSourceTime: .zero)
        
        writerInput.requestMediaDataWhenReady(on: .global(qos: .utility)) { [weak self] in
            guard let self else { return }
            
            let writerInput = self.writer.inputs[0]
            let readerOutput = self.reader.outputs[0]
            
            while writerInput.isReadyForMoreMediaData {
                guard !self.didFinishProcessing else { return }
                
                guard let sampleBuffer = readerOutput.copyNextSampleBuffer(),
                      let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer)
                else {
                    guard !self.didFinishProcessing else { break }
                    self.didFinishProcessing = true
                    
                    writerInput.markAsFinished()
                    self.finishWriting(duration: duration)
                    
                    break
                }
                
                self.processBlockBuffer(blockBuffer, channelCount: channelCount, downsampleFactor: downsampleFactor)
                
                while !writerInput.isReadyForMoreMediaData {
                    usleep(1000)
                }
                
                if !writerInput.append(sampleBuffer) {
                    self.reader.cancelReading()
                    self.writer.cancelWriting()
                    
                    if let error = writer.error {
                        self.finish(with: .writer(error))
                    } else if let error = reader.error {
                        self.finish(with: .reader(error))
                    } else {
                        self.finish(with: .unexpected)
                    }
                    
                    break
                }
            }
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
    
    private func normalizeWaveformSamples(duration: TimeInterval) -> RingtoneAudioWaveform {
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
            endTimeInOriginal: duration
        )
    }
    
    private func finishWriting(duration: TimeInterval) {
        writer.finishWriting { [weak self] in
            guard let self else { return }
            
            switch self.writer.status {
            case .completed:
                let waveform = normalizeWaveformSamples(duration: duration)
                let waveformURL = FileManager.default.ringtonesDirectory.appendingPathComponent(
                    "\(item.id.uuidString).json"
                )
                
                do {
                    let waveformData = try JSONEncoder().encode(waveform)
                    try waveformData.write(to: waveformURL)
                    
                    self.finish(with: (url: self.writer.outputURL, waveformURL: waveformURL, duration: duration))
                } catch {
                    do {
                        try FileManager.default.removeItem(at: self.writer.outputURL)
                    } catch {
                        print("ConvertCompatibleItemOperation failed to clean up with error: \(error)")
                    }
                    
                    self.finish(with: .failedToSaveWaveform(error))
                }
            default:
                if let error = self.reader.error {
                    self.finish(with: .reader(error))
                } else if let error = self.writer.error {
                    self.finish(with: .writer(error))
                } else {
                    self.finish(with: .unexpected)
                }
            }
        }
    }
    
    private func finish(with result: (url: URL, waveformURL: URL, duration: TimeInterval)) {
        self.completion?(.success(result))
        self.state = .finished
    }
    
    private func finish(with error: RingtoneDataConverterError) {
        self.completion?(.failure(error))
        self.state = .finished
    }
}
