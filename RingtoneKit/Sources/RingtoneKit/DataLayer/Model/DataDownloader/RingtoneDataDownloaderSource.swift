//
//  RingtoneDataDownloaderSource.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 26.03.25.
//

import Foundation

public enum RingtoneDataDownloaderSource {
    case tiktok(URL)
    case other(URL)
    
    init(url: URL) {
        switch url.host {
        case "tiktok":
            self = .tiktok(url)
        default:
            self = .other(url)
        }
    }
}
