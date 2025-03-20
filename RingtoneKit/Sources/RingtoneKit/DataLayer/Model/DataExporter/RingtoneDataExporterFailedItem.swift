//
//  RingtoneDataExporterFailedItem.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 17.03.25.
//

import Foundation

struct RingtoneDataExporterFailedItem: Sendable {
    let source: RingtoneAudio
    let error: RingtoneDataExporterError
}
