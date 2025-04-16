//
//  RingtoneDataConverterError:.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 04.03.25.
//

public enum RingtoneDataConverterError: Error, Sendable {
    case failedToCreateReader(Error)
    case failedToAddReaderOutput
    case failedToCreateWriter(Error)
    case failedToAddWriterInput
    case exportSessionError(Error)
    case loadAudioTrackError(Error)
    case unexpected
}
