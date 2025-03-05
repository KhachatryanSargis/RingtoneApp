//
//  RingtoneAudioEditorError.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 04.03.25.
//

public enum RingtoneAudioEditorError: Error, Sendable {
    case unsupportedFileType
    case failedToCreateExportSession
    case exportSession(RingtoneAssetExportSessionError)
    case unknown
}
