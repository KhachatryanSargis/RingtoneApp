//
//  RingtoneDataDownloaderCompleteItem.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 26.03.25.
//

import Foundation

public struct RingtoneDataDownloaderCompleteItem: IRingtoneDataConverterCompatibleItem, Sendable {
    let id: UUID
    let name: String
    let source: URL
    let url: URL
}
