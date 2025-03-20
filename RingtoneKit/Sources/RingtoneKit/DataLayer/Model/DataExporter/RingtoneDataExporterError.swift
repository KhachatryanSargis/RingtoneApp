//
//  RingtoneDataExporter.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 17.03.25.
//

enum RingtoneDataExporterError: Error {
    case failedToCopyTemplateProject(Error)
    case failedToCopyAudioFile(Error)
    case unexpected
}
