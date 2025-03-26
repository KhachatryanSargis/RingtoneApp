//
//  RingtoneDataDownloaderError.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 26.03.25.
//

public enum RingtoneDataDownloaderError: Error {
    case network
    case noAudioData
    case other(Error)
}
