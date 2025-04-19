//
//  RingtoneDataConverterError:.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 04.03.25.
//

import Foundation

public enum RingtoneDataConverterError: Error, Sendable {
    case failedToCreateReader(Error)
    case failedToAddReaderOutput
    case failedToCreateWriter(Error)
    case failedToAddWriterInput
    case loadAudioTrackError(Error)
    case reader(Error)
    case writer(Error)
    case failedToSaveWaveform(Error)
    case unexpected
    
    var isStorageFull: Bool {
        if case .writer(let error) = self {
            return (error as NSError).code == NSFileWriteOutOfSpaceError
        } else if case .failedToSaveWaveform(let error) = self {
            return (error as NSError).code == NSFileWriteOutOfSpaceError
        } else {
            return false
        }
    }
    
    var message: String {
        if isStorageFull {
            return "Your iPhone storage is full."
        } else {
            return "\(self)"
        }
    }
}
