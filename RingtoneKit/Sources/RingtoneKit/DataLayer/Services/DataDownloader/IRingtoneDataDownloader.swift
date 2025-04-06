//
//  IRingtoneDataDownloader.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 25.03.25.
//

import Foundation
import Combine

public protocol IRingtoneDataDownloader {
    // MARK: - Properties
    var progressPublisher: AnyPublisher<Progress, Never> { get }
    
    // MARK: - Methods
    func download(url: URL) -> AnyPublisher<RingtoneDataDownloaderResult, Never>
}
