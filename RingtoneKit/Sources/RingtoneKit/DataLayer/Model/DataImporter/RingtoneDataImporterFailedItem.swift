//
//  RingtoneDataImporterFailedItem.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 10.03.25.
//

import Foundation

public struct RingtoneDataImporterFailedItem: Sendable {
    let id: UUID
    let url: URL?
    let name: String
    let source: RingtoneDataImporterSource
    let error: RingtoneDataImporterError
}
