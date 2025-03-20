//
//  IRingtoneDataExporter.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 17.03.25.
//

import Combine

public protocol IRingtoneDataExporter {
    func exportRingtoneAudios(_ audios: [RingtoneAudio]) -> AnyPublisher<RingtoneDataExporterResult, Never>
}
