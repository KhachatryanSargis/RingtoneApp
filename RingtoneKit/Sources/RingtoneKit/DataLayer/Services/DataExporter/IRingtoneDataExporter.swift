//
//  IRingtoneDataExporter.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 17.03.25.
//

import Foundation
import Combine

public protocol IRingtoneDataExporter {
    func exportRingtoneAudios(_ audios: [RingtoneAudio]) -> AnyPublisher<RingtoneDataExporterResult, Never>
    func createGarageBandProject(from audio: RingtoneAudio) -> AnyPublisher<URL, RingtoneDataExporterError>
}
