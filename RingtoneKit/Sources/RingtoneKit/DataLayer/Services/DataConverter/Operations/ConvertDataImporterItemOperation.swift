//
//  ConvertDataImporterItemOperation.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 16.03.25.
//

import AVFoundation

class ConvertDataImporterItemOperation: AsyncOperation, @unchecked Sendable {
    // MARK: - Properties
    private var rootDirectoryURL: URL {
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
    
    private var session: AVAssetExportSession?
    
    private let item: RingtoneDataImporterCompleteItem
    private let completion: ((Result<(url: URL, asset: AVAsset), RingtoneDataConverterError>) -> Void)?
    
    // MARK: - Methods
    init(
        item: RingtoneDataImporterCompleteItem,
        completion: ((Result<(url: URL, asset: AVAsset), RingtoneDataConverterError>) -> Void)?
    ) {
        self.item = item
        self.completion = completion
    }
    
    override func main() {
        let asset = AVURLAsset(url: item.url)
        
        asset.loadTracks(withMediaType: AVMediaType.audio) { [weak self] tracks, error in
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
            
            let composition = AVMutableComposition()
            composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            
            do {
                try composition.insertTimeRange(track.timeRange, of: asset, at: CMTime.zero)
            } catch {
                completion?(.failure(.unexpected))
                
                self.state = .finished
                return
            }
            
            guard let session = AVAssetExportSession(
                asset: composition,
                presetName: AVAssetExportPresetAppleM4A
            ) else {
                completion?(.failure(.failedToCreateExportSession))
                
                self.state = .finished
                return
            }
            
            let fileName = item.id.uuidString + ".aiff"
            let outputURL = rootDirectoryURL.appendingPathComponent(fileName)
            
            session.outputURL = outputURL
            session.outputFileType = .m4a
            
            self.session = session
            
            session.exportAsynchronously { [weak self] in
                guard let self = self else { return }
                
                defer { self.state = .finished }
                
                guard let session = self.session
                else {
                    completion?(.failure(.unexpected))
                    return
                }
                
                session.cancelExport()
                
                if let error = session.error {
                    completion?(.failure(.exportSessionError(error)))
                    return
                }
                
                switch session.status {
                case .completed:
                    guard let outputURL = session.outputURL
                    else {
                        completion?(.failure(.unexpected))
                        return
                    }
                    
                    completion?(.success((outputURL, asset)))
                default:
                    completion?(.failure(.unexpected))
                }
            }
        }
    }
}
