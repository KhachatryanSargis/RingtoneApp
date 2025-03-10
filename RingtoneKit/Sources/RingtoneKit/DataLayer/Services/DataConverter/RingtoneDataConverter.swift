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
    
    public func convertDataImporterLocalItems(_ items: [RingtoneDataImporterLocalItem]) -> AnyPublisher<RingtoneDataConverterResult, Never> {
        Deferred {
            Future { [weak self] promise in
                guard let self = self else { return }
                
                guard !items.isEmpty
                else {
                    promise(.success(.init(audios: [], errors: [])))
                    return
                }
                
                for item in items {
                    createExportSessionForItem(item) { session in
                        guard let exportSession = session else { return }
                        
                        self.configureExportSession(exportSession, withItem: item)
                        
                        self.processExportSession(exportSession, withItem: item)
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
    private func createExportSessionForItem(
        _ item: RingtoneDataImporterLocalItem,
        completion: @Sendable @escaping (_ session: AVAssetExportSession?) -> Void
    ) {
        group.enter()
        
        let accessing = item.url.startAccessingSecurityScopedResource()
        
        let asset = AVURLAsset(url: item.url)
        
        guard let session = AVAssetExportSession(
            asset: asset,
            presetName: AVAssetExportPresetAppleM4A
        ) else {
            if accessing { item.url.stopAccessingSecurityScopedResource() }
            
            self.errorLock.lock()
            self.errors.append(.failedToCreateExportSession)
            self.errorLock.unlock()
            
            self.group.leave()
            completion(nil)
            return
        }
        
        self.sessionLock.lock()
        self.sessions[item.url] = session
        self.sessionLock.unlock()
        
        completion(session)
    }
}

// MARK: - Configure Export Session
extension RingtoneDataConverter {
    private func configureExportSession(
        _ session: AVAssetExportSession,
        withItem item: RingtoneDataImporterLocalItem
    ) {
        let fileName = item.id.uuidString + ".m4a"
        let outputURL = rootDirectoryURL.appendingPathComponent(fileName)
        
        session.outputURL = outputURL
        session.outputFileType = .m4a
    }
}

// MARK: - Process Export Session
extension RingtoneDataConverter {
    private func processExportSession(
        _ session: AVAssetExportSession,
        withItem item: RingtoneDataImporterLocalItem
    ) {
        session.exportAsynchronously { [weak self] in
            guard let self = self else { return }
            
            self.sessionLock.lock()
            guard let session = self.sessions[item.url]
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
                        id: item.id.uuidString,
                        title: item.name,
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
        
        item.url.stopAccessingSecurityScopedResource()
    }
}
