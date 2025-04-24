//
//  TrimAudioOperation.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 16.04.25.
//

import AVFoundation
import Accelerate

final class TrimAudioOperation: AsyncOperation, @unchecked Sendable {
    // MARK: - Properties
    private var channelCount: Int = 2
    private var sampleRate: Double = 44100
    private var waveformSamples: [Float] = []
    private var didFinishProcessing = false
    
    private var reader: AVAssetReader!
    private var writer: AVAssetWriter!
    private var encoder = JSONEncoder()
    private let temporaryID = UUID()
    
    private let audio: RingtoneAudio
    private let start: TimeInterval
    private let end: TimeInterval
    private let mode: RingtoneDataEditorMode
    private let completion: ((Result<RingtoneAudio, RingtoneDataEditorError>) -> Void)?
    
    // MARK: - Methods
    init(
        audio: RingtoneAudio,
        start: TimeInterval,
        end: TimeInterval,
        mode: RingtoneDataEditorMode,
        completion: ((Result<RingtoneAudio, RingtoneDataEditorError>) -> Void)?
    ) {
        self.audio = audio
        self.start = start
        self.end = end
        self.mode = mode
        self.completion = completion
    }
    
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
        
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(
            "\(temporaryID.uuidString).aiff"
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
                self.finish(with: .missingAudioTrack)
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
        
        let readerSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: sampleRate,
            AVNumberOfChannelsKey: channelCount,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsNonInterleaved: false,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false
        ]
        
        let writerSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: sampleRate,
            AVNumberOfChannelsKey: channelCount,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsNonInterleaved: false,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: true
        ]
        
        let readerOutput = AVAssetReaderTrackOutput(track: track, outputSettings: readerSettings)
        readerOutput.alwaysCopiesSampleData = false
        
        guard reader.canAdd(readerOutput)
        else {
            finish(with: .failedToAddReaderOutput)
            return
        }
        reader.add(readerOutput)
        
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
        let duration = end - start
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
                    self.finishWriting()
                    
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
    
    private func finishWriting() {
        writer.finishWriting { [weak self] in
            guard let self else { return }
            
            switch self.writer.status {
            case .completed:
                switch self.mode {
                case .replaceOriginal:
                    self.replaceOriginal()
                case .saveAsCopy:
                    self.saveAsCopy()
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
    
    private func replaceOriginal() {
        let backupURL = FileManager.default.temporaryDirectory.appendingPathComponent(
            "\(audio.id).aiff"
        )
        
        // Deleting backup and trimmed audio files.
        defer {
            cleanup(urls: [backupURL, writer.outputURL])
        }
        
        // Creating a backup of the original audio file.
        do {
            if FileManager.default.fileExists(atPath: backupURL.path) {
                try FileManager.default.removeItem(at: backupURL)
            }
            try FileManager.default.copyItem(at: audio.url, to: backupURL)
        } catch {
            finish(with: .failedToSaveAudio(error))
            return
        }
        
        // Saving changed audio file.
        let audioURL: URL
        
        do {
            guard let url = try FileManager.default.replaceItemAt(
                audio.url,
                withItemAt: writer.outputURL
            ) else {
                finish(with: .unexpected)
                return
            }
            
            audioURL = url
        } catch {
            finish(with: .failedToSaveAudio(error))
            return
        }
        
        // Saving changed waveform.
        let waveform = normalizeWaveformSamples()
        let waveformURL = audio.waveformURL
        
        do {
            let waveformData = try encoder.encode(waveform)
            try waveformData.write(to: waveformURL, options: .atomic)
        } catch {
            // Restoring the original audio file.
            do {
                let restoredURL = try FileManager.default.replaceItemAt(audio.url, withItemAt: backupURL)
                
                precondition(
                    restoredURL == audio.url,
                    "TrimAudioOperation changed original audio file URL after restoring it."
                )
            } catch {
                print("TrimAudioOperation failed to restore original audio file with error: \(error)")
            }
            
            finish(with: .failedToSaveWaveform(error))
            return
        }
        
        let formattedDuration = (end - start).shortFormatted()
        let formattedSize = audioURL.getFormattedFileSize()
        let description = "\(formattedDuration) • \(formattedSize)"
        
        let trimmedAudio = audio
            .changeDescription(description)
            .changeURL(audioURL)
            .changeWaveformURL(waveformURL)
            .paused()
        
        self.finish(with: trimmedAudio)
    }
    
    private func saveAsCopy() {
        // Saving changed audio file.
        let audioURL = FileManager.default.ringtonesDirectory.appendingPathComponent(
            "\(temporaryID.uuidString).aiff"
        )
        
        do {
            try FileManager.default.copyItem(at: writer.outputURL, to: audioURL)
            
            // Deleting the duplicate audio file (temporary directory).
            try? FileManager.default.removeItem(at: writer.outputURL)
        } catch {
            finish(with: .failedToSaveAudio(error))
            return
        }
        
        // Saving changed waveform.
        let waveform = normalizeWaveformSamples()
        let waveformURL = FileManager.default.ringtonesDirectory.appendingPathComponent(
            "\(temporaryID.uuidString).json"
        )
        
        do {
            let waveformData = try encoder.encode(waveform)
            try waveformData.write(to: waveformURL)
        } catch {
            // Deleting the audio file.
            cleanup(urls: [audioURL])
            
            finish(with: .failedToSaveWaveform(error))
            return
        }
        
        let formattedDuration = (end - start).shortFormatted()
        let formattedSize = audioURL.getFormattedFileSize()
        let description = "\(formattedDuration) • \(formattedSize)"
        
        let trimmedAudio = audio
            .changeID(temporaryID.uuidString)
            .changeDescription(description)
            .changeURL(audioURL)
            .changeWaveformURL(waveformURL)
            .paused()
        
        self.finish(with: trimmedAudio)
    }
    
    private func finish(with audio: RingtoneAudio) {
        self.completion?(.success(audio))
        self.state = .finished
    }
    
    private func finish(with error: RingtoneDataEditorError) {
        self.completion?(.failure(error))
        self.state = .finished
    }
    
    private func cleanup(urls: [URL]) {
        for url in urls {
            do {
                if FileManager.default.fileExists(atPath: url.path) {
                    try FileManager.default.removeItem(at: url)
                }
            } catch {
                print("TrimAudioOperation failed to clean up with error: \(error)")
            }
        }
    }
}
