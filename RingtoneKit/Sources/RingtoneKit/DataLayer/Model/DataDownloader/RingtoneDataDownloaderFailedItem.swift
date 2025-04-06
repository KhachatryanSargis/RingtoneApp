//
//  RingtoneDataDownloaderFailedItem.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 26.03.25.
//

import Foundation

public struct RingtoneDataDownloaderFailedItem {
    public let id: UUID
    public let name: String
    public let source: URL
    public let error: RingtoneDataDownloaderError
}
