//
//  RingtoneDataDownloader.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 27.03.25.
//

import Foundation
import Combine
import Alamofire
import UniformTypeIdentifiers

public final class RingtoneDataDownloader: IRingtoneDataDownloader, @unchecked Sendable {
    // MARK: - Properties
    public var progressPublisher: AnyPublisher<Progress, Never> {
        progressSubject.eraseToAnyPublisher()
    }
    private let progressSubject = PassthroughSubject<Progress, Never>()
    
    // MARK: - Methods
    public init() {}
    
    public func download(url: URL) -> AnyPublisher<RingtoneDataDownloaderResult, Never> {
        checkMimeType(url: url)
            .flatMap { utType -> AnyPublisher<RingtoneDataDownloaderResult, Never> in
                let tempFolderURL = FileManager.default.temporaryDirectory
                let `extension` = utType.preferredFilenameExtension ?? "mp3"
                let destinationURL = tempFolderURL.appendingPathComponent("\(UUID().uuidString).\(`extension`)")
                
                return AF.download(url, to: { _, _ in
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
                            url: destinationURL
                        )
                    case .failure(let error):
                        return self.createFailedItemResult(
                            source: url,
                            error: error
                        )
                    }
                }
                .eraseToAnyPublisher()
            }
            .catch { [unowned self] error -> Just<RingtoneDataDownloaderResult> in
                let failedItemResult = self.createFailedItemResult(
                    source: url,
                    error: error
                )
                return Just(failedItemResult)
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Check Mime Type
extension RingtoneDataDownloader {
    private func checkMimeType(url: URL) -> AnyPublisher<UTType, RingtoneDataDownloaderError> {
        AF.request(url, method: .head)
            .validate()
            .publishResponse(using: .data)
            .tryMap { response -> UTType in
                guard let mimeType = response.response?.mimeType else {
                    throw RingtoneDataDownloaderError.missingMimeType
                }
                
                if let utType = UTType(mimeType: mimeType) {
                    if utType.conforms(to: .audio) || utType.conforms(to: .video) || utType.conforms(to: .movie) {
                        return utType
                    } else {
                        let pathExtension = url.pathExtension
                        guard let utType = UTType(filenameExtension: pathExtension),
                              utType.conforms(to: .audio) || utType.conforms(to: .video) || utType.conforms(to: .movie)
                        else {
                            throw RingtoneDataDownloaderError.unsupportedMimeType
                        }
                        
                        return utType
                    }
                } else {
                    let pathExtension = url.pathExtension
                    guard let utType = UTType(filenameExtension: pathExtension),
                          utType.conforms(to: .audio) || utType.conforms(to: .video) || utType.conforms(to: .movie)
                    else {
                        throw RingtoneDataDownloaderError.unsupportedMimeType
                    }
                    
                    return utType
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
extension RingtoneDataDownloader {
    private func createCompleteItemResult(source: URL, url: URL) -> RingtoneDataDownloaderResult {
        let completeItem = RingtoneDataDownloaderCompleteItem(
            id: UUID(),
            name: source.lastPathComponent.replacingOccurrences(of: source.pathExtension, with: ""),
            source: source,
            url: url
        )
        
        return .complete(completeItem)
    }
}

// MARK: - Failed Item Result
extension RingtoneDataDownloader {
    private func createFailedItemResult(source: URL, error: Error) -> RingtoneDataDownloaderResult {
        let downloaderError = convertErrorToDownloaderError(error)
        
        let failedItem = RingtoneDataDownloaderFailedItem(
            id: UUID(),
            name: source.lastPathComponent.replacingOccurrences(of: source.pathExtension,with: ""),
            source: source,
            error: downloaderError
        )
        
        return .failed(failedItem)
    }
}

// MARK: - Convert Error
extension RingtoneDataDownloader {
    private func convertErrorToDownloaderError(_ error: Error) -> RingtoneDataDownloaderError {
        if let error = error as? RingtoneDataDownloaderError {
            return error
        } else if let error = error as? AFError {
            if let urlError = error.underlyingError as? URLError,
               urlError.code == .notConnectedToInternet || urlError.code == .networkConnectionLost {
                return RingtoneDataDownloaderError.network
            } else {
                return RingtoneDataDownloaderError.other(error)
            }
        } else {
            return RingtoneDataDownloaderError.other(error)
        }
    }
}
