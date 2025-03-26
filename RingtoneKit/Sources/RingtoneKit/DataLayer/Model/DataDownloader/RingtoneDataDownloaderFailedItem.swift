//
//  RingtoneDataDownloaderFailedItem.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 26.03.25.
//

import Foundation

public struct RingtoneDataDownloaderFailedItem {
    let id: UUID
    let name: String
    let source: URL
    let error: RingtoneDataDownloaderError
}
