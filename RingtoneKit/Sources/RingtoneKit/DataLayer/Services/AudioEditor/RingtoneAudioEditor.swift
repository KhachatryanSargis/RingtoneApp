//
//  IRingtoneAudioEditor.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 04.03.25.
//

import AVFoundation
import Combine

public enum RingtoneAudioEditorError: Error, Sendable {
    case unsupportedFileType
    case failedToCreateExportSession
    case exportSession(RingtoneAssetExportSessionError)
}



public class RingtoneAudioEditor: IRingtoneAudioEditor {
    // MARK: - Properties
    private var rootDirectoryURL: URL {
        guard let documentDirectoryURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            fatalError("documents directory url not found")
        }
        
        let ringtonesDirectoryURL = documentDirectoryURL.appendingPathComponent(
            "ringtones",
            isDirectory: true
        )
        
        // This will fail only if the directory has already been created.
        try? FileManager.default.createDirectory(
            at: ringtonesDirectoryURL,
            withIntermediateDirectories: false
        )
        
        return ringtonesDirectoryURL
    }
    
    // MARK: - Methods
    public init() {}
    
    public func convertToAudioRingtone(_ url: URL) -> AnyPublisher<RingtoneAudio, RingtoneAudioEditorError> {
        convertToM4A(url: url)
            .map { newUrl in
                return RingtoneAudio(
                    title: "New Ringtone",
                    url: newUrl
                )
            }
            .eraseToAnyPublisher()
    }
    
    private func convertToM4A(url: URL) -> AnyPublisher<URL, RingtoneAudioEditorError> {
        let asset = AVAsset(url: url)
        
        guard asset.tracks(withMediaType: .audio).first != nil else {
            return Fail<URL, RingtoneAudioEditorError>(
                error: .unsupportedFileType
            )
            .eraseToAnyPublisher()
        }
        
        guard let exportSession = RingtoneAssetExportSession(
            asset: asset,
            presetName: AVAssetExportPresetAppleM4A
        ) else {
            return Fail<URL, RingtoneAudioEditorError>(
                error: .failedToCreateExportSession
            )
            .eraseToAnyPublisher()
        }
        
        let fileName = UUID().uuidString + ".m4a"
        let outputURL = rootDirectoryURL.appendingPathComponent(fileName)
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .m4a
        
        return Deferred {
            exportSession.start()
                .mapError { .exportSession($0) }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}
