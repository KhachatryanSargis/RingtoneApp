//
//  RingtoneDataImporter.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 05.03.25.
//

import Foundation
import Combine
import UniformTypeIdentifiers

public final class RingtoneDataImporter: IRingtoneDataImporter, @unchecked Sendable {
    // MARK: - Properties
    private let fileCoordinator = NSFileCoordinator()
    private var convertedURLs: [URL] = []
    private var importedURLs: [URL: URL] = [:]
    private var errors: [RingtoneDataImporterError] = []
    
    // MARK: - Methods
    public init() {}
    
    public func importDataFromItemProviders(_ itemProviders: [NSItemProvider]) -> AnyPublisher<RingtoneDataImporterResult, Never> {
        Deferred {
            Future { [weak self] promise in
                guard let self = self else { return }
                
                guard !itemProviders.isEmpty
                else {
                    promise(.success(.init(urls: [], errors: [])))
                    return
                }
                
                self.getURLsFromItemProviders(itemProviders) { urls in
                    self.getResultFromUrls(urls) { result in
                        promise(.success(result))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func importDataFromURLs(_ urls: [URL]) -> AnyPublisher<RingtoneDataImporterResult, Never> {
        Deferred {
            Future { [weak self] promise in
                guard let self = self else { return }
                
                guard !urls.isEmpty
                else {
                    promise(.success(.init(urls: [], errors: [])))
                    return
                }
                
                self.getResultFromUrls(urls) { result in
                    promise(.success(result))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Result From URLs
extension RingtoneDataImporter {
    private func getResultFromUrls(_ urls: [URL], comletion: @escaping (_ result: RingtoneDataImporterResult) -> Void) {
        let group = DispatchGroup()
        let lock = NSLock()
        
        for url in urls {
            group.enter()
            
            let accessing = url.startAccessingSecurityScopedResource()
            
            fileCoordinator.coordinate(readingItemAt: url, error: nil) { [weak self] newURL in
                guard let self = self else { return }
                
                if accessing { url.stopAccessingSecurityScopedResource() }
                
                lock.lock()
                self.importedURLs[url] = newURL
                lock.unlock()
                
                group.leave()
            }
        }
        
        group.notify(queue: .global()) {
            for url in urls {
                if self.importedURLs[url] == nil {
                    self.errors.append(.failedToReadDataFromURL(url))
                }
            }
            
            let newURLs = self.importedURLs.map { $0.value }
            let errors = self.errors
            
            self.importedURLs = [:]
            self.errors = []
            
            comletion(.init(urls: newURLs, errors: errors))
        }
    }
}

// MARK: - URLs From Item Providers
extension RingtoneDataImporter {
    private func getURLsFromItemProviders(
        _ itemProviders: [NSItemProvider],
        completion: @escaping (_ urls: [URL]) -> Void
    ) {
        let group = DispatchGroup()
        let urlLock = NSLock()
        let errorLock = NSLock()
        
        for itemProvider in itemProviders {
            group.enter()
            
            guard let typeIdentifier = itemProvider.registeredTypeIdentifiers.first,
                  let utType = UTType(typeIdentifier),
                  utType.conforms(to: .movie)
            else {
                errorLock.lock()
                self.errors.append(.unsupportedDataFormat)
                errorLock.unlock()
                
                group.leave()
                continue
            }
            
            itemProvider.loadItem(forTypeIdentifier: typeIdentifier) { [weak self] url, error in
                guard let self = self else { return }
                
                if let error = error {
                    errorLock.lock()
                    self.errors.append(.failedToGetURLFromItemProvider(error))
                    errorLock.unlock()
                    
                    group.leave()
                    return
                }
                
                guard let url = url as? URL
                else {
                    errorLock.lock()
                    self.errors.append(.unexpected)
                    errorLock.unlock()
                    
                    group.leave()
                    return
                }
                
                urlLock.lock()
                self.convertedURLs.append(url)
                urlLock.unlock()
                
                group.leave()
            }
        }
        
        group.notify(queue: .global()) { [weak self] in
            guard let self = self else { return }
            
            let urls = self.convertedURLs
            self.convertedURLs = []
            completion(urls)
        }
    }
}
