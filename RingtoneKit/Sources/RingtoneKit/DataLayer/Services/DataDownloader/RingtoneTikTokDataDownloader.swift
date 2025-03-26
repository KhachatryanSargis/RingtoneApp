//
//  RingtoneTikTokDataDownloader.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 26.03.25.
//

import Foundation
import Combine
import Alamofire

public final class RingtoneTikTokDataDownloader: IRingtoneDataDownloader {
    private struct TikTikDownloadInfo: Codable {
        let author: String
        let links: [TikTokLink]
    }
    
    private struct TikTokLink: Codable {
        let type: String
        let source: String
        let url: String
        
        enum CodingKeys: String, CodingKey {
            case type = "t"
            case source = "s"
            case url = "a"
        }
    }
    
    // MARK: - Methods
    public init() {}
    
    public func download(url: URL) -> AnyPublisher<RingtoneDataDownloaderResult, Never> {
        let parameters: [String: String] = [
            "query": url.absoluteString
        ]
        
        return AF.request(
            "https://lovetik.com/api/ajax/search",
            method: .post,
            parameters: parameters,
            encoding: URLEncoding.default
        )
        .validate()
        .publishDecodable(type: TikTikDownloadInfo.self)
        .flatMap { response -> AnyPublisher<RingtoneDataDownloaderResult, Never> in
            switch response.result {
            case .success(let info):
                if let link = info.links.first(where: { $0.type.contains("MP3") }) {
                    let tempFolderURL = FileManager.default.temporaryDirectory
                    let destinationURL = tempFolderURL.appendingPathComponent("\(UUID().uuidString).mp3")
                    
                    return AF.download(link.url, to: { a, b in
                        (destinationURL, [.removePreviousFile, .createIntermediateDirectories])
                    })
                    .publishURL()
                    .map { _ in
                        let item = RingtoneDataDownloaderCompleteItem(
                            id: UUID(),
                            name: info.author,
                            source: url,
                            url: destinationURL
                        )
                        return RingtoneDataDownloaderResult.complete(item)
                    }
                    .eraseToAnyPublisher()
                } else {
                    let failedItem = RingtoneDataDownloaderFailedItem(
                        id: UUID(),
                        name: info.author,
                        source: url,
                        error: .noAudioData
                    )
                    return Just(RingtoneDataDownloaderResult.failed(failedItem))
                        .eraseToAnyPublisher()
                }
                
            case .failure(let error):
                let failedItem = RingtoneDataDownloaderFailedItem(
                    id: UUID(),
                    name: url.lastPathComponent.replacingOccurrences(
                        of: url.pathExtension,
                        with: ""
                    ),
                    source: url,
                    error: .other(error)
                )
                return Just(RingtoneDataDownloaderResult.failed(failedItem))
                    .eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }
}
