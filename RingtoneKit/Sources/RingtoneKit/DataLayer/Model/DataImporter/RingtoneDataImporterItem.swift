//
//  RingtoneDataImporterItem.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 10.03.25.
//

import Foundation

public struct RingtoneDataImporterItem: Sendable {
    let id: UUID
    let name: String
    let result: Result<URL, RingtoneDataImporterError>
    let isRemote: Bool
}
