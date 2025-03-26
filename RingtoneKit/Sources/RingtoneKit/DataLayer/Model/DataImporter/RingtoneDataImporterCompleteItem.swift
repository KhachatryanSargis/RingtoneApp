//
//  RingtoneDataImporterCompleteItem.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 10.03.25.
//

import Foundation

public struct RingtoneDataImporterCompleteItem: IRingtoneDataConverterCompatibleItem, Sendable {
    let id: UUID
    let name: String
    let source: RingtoneDataImporterSource
    let url: URL
}
