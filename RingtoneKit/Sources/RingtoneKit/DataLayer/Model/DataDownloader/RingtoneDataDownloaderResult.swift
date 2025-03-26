//
//  RingtoneDataDownloaderResult.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 26.03.25.
//

public enum RingtoneDataDownloaderResult {
    case complete(RingtoneDataDownloaderCompleteItem)
    case failed(RingtoneDataDownloaderFailedItem)
}
