//
//  RingtoneDataExporterError.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 17.03.25.
//

enum RingtoneDataExporterError: Error {
    case failedToCreateProjectStructure(Error)
    case failedToCopyProjectDataFile(Error)
    case failedToCopyAudioFile(Error)
}
