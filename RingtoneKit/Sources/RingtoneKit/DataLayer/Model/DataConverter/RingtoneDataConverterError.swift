//
//  RingtoneDataConverterError:.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 04.03.25.
//

public enum RingtoneDataConverterError: Error, Sendable {
    case failedToCreateExportSession
    case failedToCreateGarageBandProject
    case exportSessionError(Error)
    case unexpected
}
