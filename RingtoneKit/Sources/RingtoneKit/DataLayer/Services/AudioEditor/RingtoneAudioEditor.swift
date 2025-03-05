//
//  RingtoneAudioEditor.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 04.03.25.
//

import AVFoundation
import Combine

public final class RingtoneAudioEditor: IRingtoneAudioEditor {
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
    
    // MARK: - Methods
    public init() {}
    
    public func convertToAudioRingtone(_ url: URL, suggestedName: String?) -> AnyPublisher<RingtoneAudio, RingtoneAudioEditorError> {
        Deferred { [weak self] in
            guard let self = self else {
                return Fail<RingtoneAudio, RingtoneAudioEditorError>(
                    error: .unknown
                )
                .eraseToAnyPublisher()
            }
            
            let asset = AVURLAsset(url: url)
            
            guard let exportSession = RingtoneAssetExportSession(
                asset: asset,
                presetName: AVAssetExportPresetAppleM4A
            ) else {
                return Fail<RingtoneAudio, RingtoneAudioEditorError>(
                    error: .failedToCreateExportSession
                )
                .eraseToAnyPublisher()
            }
            
            let id = UUID().uuidString
            let fileName = id + ".band"
            let outputURL = rootDirectoryURL.appendingPathComponent(fileName)
            let title = suggestedName ?? "My Ringtone"
            
            exportSession.outputURL = outputURL
            exportSession.outputFileType = .m4a
            
            return exportSession.start()
                .mapError { .exportSession($0) }
                .map { url in
                    RingtoneAudio(
                        id: id,
                        title: title,
                        url: url
                    )
                }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}
