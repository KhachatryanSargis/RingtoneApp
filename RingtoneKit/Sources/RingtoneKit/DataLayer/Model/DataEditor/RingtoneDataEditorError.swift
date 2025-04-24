//
//  RingtoneDataEditorError.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 16.04.25.
//

public enum RingtoneDataEditorError: Error {
    case failedToCreateReader(Error)
    case failedToAddReaderOutput
    case failedToCreateWriter(Error)
    case failedToAddWriterInput
    case loadAudioTrackError(Error)
    case missingAudioTrack
    case reader(Error)
    case writer(Error)
    case failedToSaveAudio(Error)
    case failedToSaveWaveform(Error)
    case unexpected
}
