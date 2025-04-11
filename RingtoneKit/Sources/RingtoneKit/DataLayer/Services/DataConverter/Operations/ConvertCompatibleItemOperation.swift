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
    private static var rootDirectoryURL: URL {
        guard let documentDirectoryURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            fatalError("documents directory url not found")
        }
        
        let ringtonesDirectoryURL = documentDirectoryURL.appendingPathComponent(
            "Ringtones",
            isDirectory: true
        )
        
        // This will fail only if the directory has already been created.
        try? FileManager.default.createDirectory(
            at: ringtonesDirectoryURL,
            withIntermediateDirectories: false
        )
        
        return ringtonesDirectoryURL
    }
    
    //    private var session: AVAssetExportSession?
    
    private let reader: AVAssetReader
    private let writer: AVAssetWriter
    
    private let item: IRingtoneDataConverterCompatibleItem
    private let completion: ((Result<(url: URL, asset: AVAsset), RingtoneDataConverterError>) -> Void)?
    
    // MARK: - Methods
    init(
        item: IRingtoneDataConverterCompatibleItem,
        completion: ((Result<(url: URL, asset: AVAsset), RingtoneDataConverterError>) -> Void)?
    ) {
        self.item = item
        self.completion = completion
        
        let asset = AVURLAsset(url: item.url)
        
        // TODO: Handle the error properly!
        reader = try! AVAssetReader(asset: asset)
        
        let fileName = item.id.uuidString + ".aiff"
        let outputURL = Self.rootDirectoryURL.appendingPathComponent(fileName)
        
        // TODO: Handle the error properly!
        writer = try! AVAssetWriter(outputURL: outputURL, fileType: .aiff)
    }
    
    override func main() {
        reader.asset.loadTracks(withMediaType: AVMediaType.audio) {
            [weak self] tracks,
            error in
            guard let self = self else { return }
            
            if let error = error {
                completion?(.failure(.loadAudioTrackError(error)))
                
                self.state = .finished
                return
            }
            
            guard let track = tracks?.first else {
                completion?(.failure(.unexpected))
                
                self.state = .finished
                return
            }
            
            let readerOutputSettings: [String: Any] = [
                AVFormatIDKey: kAudioFormatLinearPCM,
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 2,
                AVLinearPCMBitDepthKey: 16,
                AVLinearPCMIsNonInterleaved: false,
                AVLinearPCMIsFloatKey: false,
                AVLinearPCMIsBigEndianKey: false
            ]
            
            let readerOutput = AVAssetReaderTrackOutput(track: track, outputSettings: readerOutputSettings)
            self.reader.add(readerOutput)
            
            let writerOutputSettings: [String: Any] = [
                AVFormatIDKey: kAudioFormatLinearPCM,
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 2,
                AVLinearPCMBitDepthKey: 16,
                AVLinearPCMIsNonInterleaved: false,
                AVLinearPCMIsFloatKey: false,
                AVLinearPCMIsBigEndianKey: true
            ]
            
            let writerInput = AVAssetWriterInput(mediaType: .audio, outputSettings: writerOutputSettings)
            writerInput.expectsMediaDataInRealTime = false
            self.writer.add(writerInput)
            
            self.reader.startReading()
            self.writer.startWriting()
            self.writer.startSession(atSourceTime: .zero)
            
            writerInput.requestMediaDataWhenReady(on: .global(qos: .utility)) { [weak self] in
                guard let self = self else { return }
                
                let writerInput = self.writer.inputs[0]
                let readerOutput = self.reader.outputs[0]
                
                while true {
                    if !writerInput.isReadyForMoreMediaData { return }
                    
                    if let sampleBuffer = readerOutput.copyNextSampleBuffer() {
                        let success = writerInput.append(sampleBuffer)
                        
                        if !success {
                            self.reader.cancelReading()
                            self.writer.cancelWriting()
                            
                            self.completion?(.failure(.unexpected))
                            self.state = .finished
                            
                            return
                        }
                    } else {
                        writerInput.markAsFinished()
                        
                        self.writer.finishWriting {
                            switch self.writer.status {
                            case .completed:
                                self.completion?(.success((self.writer.outputURL, self.reader.asset)))
                            default:
                                if let error = self.writer.error {
                                    self.completion?(.failure(.exportSessionError(error)))
                                } else {
                                    self.completion?(.failure(.unexpected))
                                }
                            }
                            
                            self.state = .finished
                        }
                        return
                    }
                }
            }
            
            // Alternative Implementation
            //            let composition = AVMutableComposition()
            //            composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            //
            //            do {
            //                try composition.insertTimeRange(track.timeRange, of: asset, at: CMTime.zero)
            //            } catch {
            //                completion?(.failure(.unexpected))
            //
            //                self.state = .finished
            //                return
            //            }
            //
            //            guard let session = AVAssetExportSession(
            //                asset: composition,
            //                presetName: AVAssetExportPresetAppleM4A
            //            ) else {
            //                completion?(.failure(.failedToCreateExportSession))
            //
            //                self.state = .finished
            //                return
            //            }
            //
            //            let fileName = item.id.uuidString + ".m4a"
            //            let outputURL = rootDirectoryURL.appendingPathComponent(fileName)
            //
            //            session.outputURL = outputURL
            //            session.outputFileType = .m4a
            //
            //            self.session = session
            //
            //            session.exportAsynchronously { [weak self] in
            //                guard let self = self else { return }
            //
            //                defer { self.state = .finished }
            //
            //                guard let session = self.session
            //                else {
            //                    completion?(.failure(.unexpected))
            //                    return
            //                }
            //
            //                if let error = session.error {
            //                    completion?(.failure(.exportSessionError(error)))
            //                    return
            //                }
            //
            //                switch session.status {
            //                case .completed:
            //                    guard let outputURL = session.outputURL
            //                    else {
            //                        completion?(.failure(.unexpected))
            //                        return
            //                    }
            //
            //                    completion?(.success((outputURL, asset)))
            //                default:
            //                    completion?(.failure(.unexpected))
            //                }
            //            }
        }
    }
}
