//
//  RingtoneDataConverter.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 04.03.25.
//

import AVFoundation
import Combine

public final class RingtoneDataConverter: IRingtoneDataConverter, @unchecked Sendable {
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
    
    private var audios: [RingtoneAudio] = []
    private var sessions: [URL: AVAssetExportSession] = [:]
    private var errors: [RingtoneDataConverterError] = []
    
    private let group = DispatchGroup()
    private let audioLock = NSLock()
    private let sessionLock = NSLock()
    private let errorLock = NSLock()
    
    // MARK: - Methods
    public init() {}
    
    public func convertToRingtoneAudios(_ urls: [URL]) -> AnyPublisher<RingtoneDataConverterResult, Never> {
        Deferred {
            Future { [weak self] promise in
                guard let self = self else { return }
                
                guard !urls.isEmpty
                else {
                    promise(.success(.init(audios: [], errors: [])))
                    return
                }
                
                for url in urls {
                    createExportSessionForUrl(url) { session in
                        guard let exportSession = session else { return }
                        
                        let id = self.configureExportSession(exportSession, withUrl: url)
                        
                        self.processExportSession(exportSession, withUrl: url, id: id)
                    }
                }
                
                group.notify(queue: .global()) {
                    let audios = self.audios
                    self.audios = []
                    
                    let errors = self.errors
                    self.errors = []
                    
                    promise(.success(.init(audios: audios, errors: errors)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Create Export Session
extension RingtoneDataConverter {
    // MARK: - Create
    private func createExportSessionForUrl(_ url: URL, completion: @Sendable @escaping (_ session: AVAssetExportSession?) -> Void) {
        group.enter()
        
        let accessing = url.startAccessingSecurityScopedResource()
        
        let asset = AVURLAsset(url: url)
        asset.loadTracks(withMediaType: AVMediaType.audio) { [weak self] tracks, error in
            guard let self = self else { return }
            
            if let error = error {
                if accessing { url.stopAccessingSecurityScopedResource() }
                
                self.errorLock.lock()
                self.errors.append(.exportSessionError(error))
                self.errorLock.unlock()
                
                self.group.leave()
                completion(nil)
                return
            }
            
            guard let track = tracks?.first else {
                if accessing { url.stopAccessingSecurityScopedResource() }
                
                self.errorLock.lock()
                self.errors.append(.unexpected)
                self.errorLock.unlock()
                
                self.group.leave()
                completion(nil)
                return
            }
            
            let composition = AVMutableComposition()
            composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            
            do {
                try composition.insertTimeRange(track.timeRange, of: asset, at: CMTime.zero)
            } catch {
                if accessing { url.stopAccessingSecurityScopedResource() }
                
                self.errorLock.lock()
                self.errors.append(.exportSessionError(error))
                self.errorLock.unlock()
                
                self.group.leave()
                completion(nil)
                return
            }
            
            guard let session = AVAssetExportSession(
                asset: composition,
                presetName: AVAssetExportPresetPassthrough
            ) else {
                if accessing { url.stopAccessingSecurityScopedResource() }
                
                self.errorLock.lock()
                self.errors.append(.failedToCreateExportSession)
                self.errorLock.unlock()
                
                self.group.leave()
                completion(nil)
                return
            }
            
            self.sessionLock.lock()
            self.sessions[url] = session
            self.sessionLock.unlock()
            
            completion(session)
        }
    }
}

// MARK: - Configure Export Session
extension RingtoneDataConverter {
    private func configureExportSession(_ session: AVAssetExportSession, withUrl url: URL) -> UUID {
        let id = UUID()
        
        let fileName = id.uuidString + ".m4a"
        let outputURL = rootDirectoryURL.appendingPathComponent(fileName)
        
        session.outputURL = outputURL
        session.outputFileType = .m4a
        
        return id
    }
}

// MARK: - Process Export Session
extension RingtoneDataConverter {
    private func processExportSession(_ session: AVAssetExportSession, withUrl url: URL, id: UUID) {
        session.exportAsynchronously { [weak self] in
            guard let self = self else { return }
            
            self.sessionLock.lock()
            guard let session = self.sessions[url]
            else {
                self.errors.append(.unexpected)
                
                group.leave()
                return
            }
            self.sessionLock.unlock()
            
            if let error = session.error {
                errorLock.lock()
                self.errors.append(.exportSessionError(error))
                errorLock.unlock()
                
                group.leave()
                return
            }
            
            switch session.status {
            case .completed:
                self.audioLock.lock()
                self.audios.append(
                    RingtoneAudio(
                        id: id.uuidString,
                        title: "My Ringtone",
                        url: session.outputURL!
                    )
                )
                self.audioLock.unlock()
                
                group.leave()
                return
            default:
                errorLock.lock()
                self.errors.append(.unexpected)
                errorLock.unlock()
                
                group.leave()
                return
            }
        }
        
        url.stopAccessingSecurityScopedResource()
    }
}
