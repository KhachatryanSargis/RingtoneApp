//
//  RingtoneDataTrimmerError.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 16.04.25.
//


public enum RingtoneDataTrimmerError: Error {
    case failedToCreateReader(Error)
    case failedToAddReaderOutput
    case failedToCreateWriter(Error)
    case failedToAddWriterInput
    case exportSessionError(Error)
    case loadAudioTrackError(Error)
    case unexpected
}