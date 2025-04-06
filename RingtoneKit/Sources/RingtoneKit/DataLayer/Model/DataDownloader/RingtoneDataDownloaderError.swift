//
//  RingtoneDataDownloaderError.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 26.03.25.
//

public enum RingtoneDataDownloaderError: Error {
    case network
    case missingMimeType
    case unsupportedMimeType
    case failedToFindData
    case other(Error)
    case unexpected
}
