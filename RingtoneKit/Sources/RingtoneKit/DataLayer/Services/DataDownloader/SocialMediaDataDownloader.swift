//
//  SocialMediaDataDownloader.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 03.04.25.
//

import Foundation
import Combine
import Alamofire

public final class SocialMediaDataDownloader: IRingtoneDataDownloader, @unchecked Sendable {
    private struct GetInfoResponse: Codable {
        let title: String
        let medias: [Media]
        
        struct Media: Codable {
            let type: String
            let `extension`: String
            let url: String
            let quality: Int
            
            enum AlternateCodingKeys: String, CodingKey {
                case `extension` = "ext"
            }
            
            init(from decoder: any Decoder) throws {
                let container: KeyedDecodingContainer = try decoder.container(keyedBy: CodingKeys.self)
                self.type = try container.decode(String.self, forKey: .type)
                self.url = try container.decode(String.self, forKey: .url)
                
                if let ext = try? container.decode(String.self, forKey: .extension) {
                    self.extension = ext
                } else {
                    let alternateContainer = try decoder.container(keyedBy: AlternateCodingKeys.self)
                    self.extension = try alternateContainer.decode(String.self, forKey: .extension)
                }
                
                func extractQualityNumber(from string: String) -> Int? {
                    let pattern = "\\((\\d+)"
                    let regex = try? NSRegularExpression(pattern: pattern, options: [])
                    if let match = regex?.firstMatch(in: string, options: [], range: NSRange(string.startIndex..., in: string)) {
                        let numberRange = match.range(at: 1)
                        if let swiftRange = Range(numberRange, in: string) {
                            let numberString = String(string[swiftRange])
                            return Int(numberString)
                        }
                    }
                    return nil
                }
                
                let qualityString = try container.decode(String.self, forKey: .quality)
                if let quality = extractQualityNumber(from: qualityString) {
                    self.quality = quality
                } else {
                    self.quality = 0
                }
            }
        }
    }
    
    private struct DownloadInfo {
        let title: String
        let `extension`: String
        let url: String
    }
    
    // MARK: - Properties
    public var progressPublisher: AnyPublisher<Progress, Never> {
        progressSubject.eraseToAnyPublisher()
    }
    private let progressSubject = PassthroughSubject<Progress, Never>()
    private let API_KEY: String
    
    // MARK: - Methods
    public init() {
        if let path = Bundle.main.path(forResource: "APIKey", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
           let apiKey = dict["x-rapidapi-key"] as? String {
            
            self.API_KEY = apiKey
        } else {
            fatalError("x-rapidapi-key not found")
        }
    }
    
    public func download(url: URL) -> AnyPublisher<RingtoneDataDownloaderResult, Never> {
        getDownloadInfoForSocialMediaURL(url)
            .flatMap { info -> AnyPublisher<RingtoneDataDownloaderResult, Never> in
                let tempFolderURL = FileManager.default.temporaryDirectory
                let destinationURL = tempFolderURL.appendingPathComponent("\(UUID().uuidString).\(info.extension)")
                
                return AF.download(info.url, to: { _, _ in
                    (destinationURL, [.removePreviousFile, .createIntermediateDirectories])
                })
                .validate()
                .downloadProgress { [weak self] progress in
                    guard let self = self else { return }
                    self.progressSubject.send(progress)
                }
                .publishURL()
                .map { [unowned self] response -> RingtoneDataDownloaderResult in
                    switch response.result {
                    case .success:
                        return self.createCompleteItemResult(
                            source: url,
                            name: info.title,
                            url: destinationURL
                        )
                    case .failure(let error):
                        return self.createFailedItemResult(
                            source: url,
                            name: info.title,
                            error: error
                        )
                    }
                }
                .eraseToAnyPublisher()
            }
            .catch { [unowned self] error -> Just<RingtoneDataDownloaderResult> in
                let failedItemResult = self.createFailedItemResult(
                    source: url,
                    name: nil,
                    error: error
                )
                
                return Just(failedItemResult)
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Get Download Info
extension SocialMediaDataDownloader {
    private func getDownloadInfoForSocialMediaURL(_ url: URL) -> AnyPublisher<DownloadInfo, RingtoneDataDownloaderError> {
        let headers: HTTPHeaders = [
            "x-rapidapi-key": API_KEY,
            "x-rapidapi-host": "social-download-all-in-one.p.rapidapi.com",
            "Content-Type": "application/json"
        ]
        
        let parameters = [
            "url": url.absoluteString
        ]
        
        return AF.request(
            "https://social-download-all-in-one.p.rapidapi.com/v1/social/autolink",
            method: .post,
            parameters: parameters,
            encoder: .json,
            headers: headers
        )
        .validate()
        .publishData()
        .tryMap { response -> DownloadInfo in
            switch response.result {
            case .success(let data):
                let info = try JSONDecoder().decode(GetInfoResponse.self, from: data)
                
                let title = info.title
                let medias = info.medias.filter { $0.extension != "opus" }
                
                if let highestAudio = medias.filter({ $0.type == "audio" }).max(by: { $0.quality < $1.quality }) {
                    return DownloadInfo(
                        title: title,
                        extension: highestAudio.extension,
                        url: highestAudio.url
                    )
                } else if let highestVideo = medias.filter({ $0.type == "video" }).max(by: { $0.quality < $1.quality }) {
                    return DownloadInfo(
                        title: title,
                        extension: highestVideo.extension,
                        url: highestVideo.url
                    )
                } else {
                    throw RingtoneDataDownloaderError.unexpected
                }
            case .failure(let error):
                throw error
            }
        }
        .mapError { [weak self] error -> RingtoneDataDownloaderError in
            guard let self = self else { return .unexpected }
            
            return self.convertErrorToDownloaderError(error)
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Complete Item Result
extension SocialMediaDataDownloader {
    private func createCompleteItemResult(source: URL, name: String, url: URL) -> RingtoneDataDownloaderResult  {
        let completeItem = RingtoneDataDownloaderCompleteItem(
            id: UUID(),
            name: name,
            source: source,
            url: url
        )
        
        return .complete(completeItem)
    }
}

// MARK: - Failed Item Result
extension SocialMediaDataDownloader {
    private func createFailedItemResult(source: URL, name: String?, error: Error) -> RingtoneDataDownloaderResult  {
        let downloaderError = convertErrorToDownloaderError(error)
        
        let failedItem = RingtoneDataDownloaderFailedItem(
            id: UUID(),
            name: name ?? source.lastPathComponent.replacingOccurrences(of: source.pathExtension, with: ""),
            source: source,
            error: downloaderError
        )
        
        return .failed(failedItem)
    }
}

// MARK: - Convert Error
extension SocialMediaDataDownloader {
    private func convertErrorToDownloaderError(_ error: Error) -> RingtoneDataDownloaderError {
        if let error = error as? RingtoneDataDownloaderError {
            return error
        } else if let error = error as? AFError {
            if let urlError = error.underlyingError as? URLError,
               urlError.code == .notConnectedToInternet || urlError.code == .networkConnectionLost {
                return RingtoneDataDownloaderError.network
            } else if error.underlyingError is DecodingError {
                return RingtoneDataDownloaderError.failedToFindData
            } else {
                return RingtoneDataDownloaderError.other(error)
            }
        } else {
            return RingtoneDataDownloaderError.other(error)
        }
    }
}

// MARK: - Check if a URL is Supported
extension SocialMediaDataDownloader {
    public static func isSupportedHost(url: URL) -> Bool {
        let supportedHosts: Set<String> = [
            "tiktok", "douyin", "capcut", "th", "instagram", "fb",
            "espn", "pinterest", "imdb", "imgur", "ifunny", "izlesene",
            "reddit", "youtube", "twitter", "vimeo", "snapchat",
            "bilibili", "dailymotion", "sharechat", "likee", "linkedin",
            "tumblr", "hipi", "telegram", "getstickerpack", "bitchute",
            "febspot", "9gag", "oke", "rumble", "streamable", "ted",
            "sohutv", "xiaohongshu", "ixigua", "weibo", "miaopai", "meipai",
            "xiaoying", "nationalvideo", "yingke", "sina", "soundcloud",
            "mixcloud", "spotify", "zingmp3", "bandcamp", "facebook"
        ]
        
        guard let host = url.host?.lowercased() else { return false }
        
        for item in supportedHosts {
            if host.contains(item) {
                return true
            } else {
                continue
            }
        }
        
        return false
    }
}
