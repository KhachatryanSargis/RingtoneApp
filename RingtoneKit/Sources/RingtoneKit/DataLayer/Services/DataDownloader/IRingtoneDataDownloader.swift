//
//  IRingtoneDataDownloader.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 25.03.25.
//

import Foundation
import Combine

public protocol IRingtoneDataDownloader {
    func download(url: URL) -> AnyPublisher<RingtoneDataDownloaderResult, Never>
}
