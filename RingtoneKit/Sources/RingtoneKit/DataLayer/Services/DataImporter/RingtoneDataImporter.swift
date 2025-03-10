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
    private var localItems: [RingtoneDataImporterLocalItem] = []
    private var remoteItems: [RingtoneDataImporterRemoteItem] = []
    private var failedItems: [RingtoneDataImporterFailedItem] = []
    
    // MARK: - Methods
    public init() {}
}

// MARK: - From Gallery
extension RingtoneDataImporter {
    public func importDataFromGallery(_ itemProviders: [NSItemProvider]) -> AnyPublisher<RingtoneDataImporterResult, Never> {
        Deferred {
            Future { [weak self] promise in
                guard let self = self else { return }
                
                guard !itemProviders.isEmpty
                else {
                    promise(
                        .success(
                            .init(
                                localItems: [],
                                remoteItems: [],
                                failedItems: []
                            )
                        )
                    )
                    return
                }
                
                let group = DispatchGroup()
                let lock = NSLock()
                
                for itemProvider in itemProviders {
                    group.enter()
                    
                    let suggestedName = itemProvider.suggestedName
                    
                    self.loadItemProvider(itemProvider) { [suggestedName] result in
                        switch result {
                        case .success(let url):
                            guard self.urlContainsData(url)
                            else {
                                lock.lock()
                                self.remoteItems.append(
                                    .init(
                                        id: UUID(),
                                        url: url,
                                        name: suggestedName ?? url.lastPathComponent
                                    )
                                )
                                lock.unlock()
                                
                                group.leave()
                                return
                            }
                            
                            do {
                                let outputURL = try self.copyDataFromUrl(url)
                                
                                lock.lock()
                                self.localItems.append(
                                    .init(
                                        id: UUID(),
                                        url: outputURL,
                                        name: suggestedName ?? url.lastPathComponent
                                    )
                                )
                                lock.unlock()
                                
                                group.leave()
                            } catch {
                                lock.lock()
                                self.failedItems.append(
                                    .init(
                                        id: UUID(),
                                        url: url,
                                        name: suggestedName ?? url.lastPathComponent,
                                        error: .failedToCopyData(error)
                                    )
                                )
                                lock.unlock()
                                
                                group.leave()
                            }
                        case .failure(let error):
                            lock.lock()
                            self.failedItems.append(
                                .init(
                                    id: UUID(),
                                    url: nil,
                                    name: suggestedName ?? "My Ringtone",
                                    error: .failedToGetURLFromItemProvider(error)
                                )
                            )
                            lock.unlock()
                            
                            group.leave()
                        }
                    }
                }
                
                group.notify(queue: .global()) {
                    let localItems = self.localItems
                    let remoteItems = self.remoteItems
                    let failedItems = self.failedItems
                    
                    self.localItems = []
                    self.remoteItems = []
                    self.failedItems = []
                    
                    promise(
                        .success(
                            .init(
                                localItems: localItems,
                                remoteItems: remoteItems,
                                failedItems: failedItems
                            )
                        )
                    )
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func importRemoteItemsFromGallery(_ items: [RingtoneDataImporterRemoteItem]) -> AnyPublisher<RingtoneDataImporterResult, Never> {
        return Deferred {
            Future { [weak self] promise in
                guard let self = self else { return }
                
                guard !items.isEmpty
                else {
                    promise(
                        .success(
                            .init(
                                localItems: [],
                                remoteItems: [],
                                failedItems: []
                            )
                        )
                    )
                    return
                }
                
                let group = DispatchGroup()
                let lock = NSLock()
                
                for item in items {
                    group.enter()
                    
                    guard let itemProvider = NSItemProvider(contentsOf: item.url)
                    else {
                        lock.lock()
                        self.failedItems.append(
                            .init(
                                id: item.id,
                                url: item.url,
                                name: item.name,
                                error: .unexpected
                            )
                        )
                        lock.unlock()
                        
                        group.leave()
                        return
                    }
                    
                    self.loadItemProvider(itemProvider, isRemote: true) { result in
                        switch result {
                        case .success(let url):
                            do {
                                let outputURL = try self.copyDataFromUrl(url)
                                
                                lock.lock()
                                self.localItems.append(
                                    .init(
                                        id: item.id,
                                        url: outputURL,
                                        name: item.name
                                    )
                                )
                                lock.unlock()
                                
                                group.leave()
                            } catch {
                                lock.lock()
                                self.failedItems.append(
                                    .init(
                                        id: item.id,
                                        url: item.url,
                                        name: item.name,
                                        error: .failedToCopyData(error)
                                    )
                                )
                                lock.unlock()
                                
                                group.leave()
                            }
                        case .failure(let error):
                            lock.lock()
                            self.failedItems.append(
                                .init(
                                    id: item.id,
                                    url: item.url,
                                    name: item.name,
                                    error: .failedToGetURLFromItemProvider(error)
                                )
                            )
                            lock.unlock()
                            
                            group.leave()
                        }
                    }
                }
                
                group.notify(queue: .global()) {
                    let localItems = self.localItems
                    let remoteItems = self.remoteItems
                    let failedItems = self.failedItems
                    
                    self.localItems = []
                    self.remoteItems = []
                    self.failedItems = []
                    
                    promise(
                        .success(
                            .init(
                                localItems: localItems,
                                remoteItems: remoteItems,
                                failedItems: failedItems
                            )
                        )
                    )
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - From Documents
extension RingtoneDataImporter {
    public func importDataFromDocuments(_ urls: [URL]) -> AnyPublisher<RingtoneDataImporterResult, Never> {
        Deferred {
            Future { [weak self] promise in
                guard let self = self else { return }
                
                guard !urls.isEmpty
                else {
                    promise(
                        .success(
                            .init(
                                localItems: [],
                                remoteItems: [],
                                failedItems: []
                            )
                        )
                    )
                    return
                }
                
                let group = DispatchGroup()
                let lock = NSLock()
                
                for url in urls {
                    group.enter()
                    
                    do {
                        let outputURL = try self.copyDataFromUrl(url)
                        
                        lock.lock()
                        self.localItems.append(
                            .init(
                                id: UUID(),
                                url: outputURL,
                                name: url.lastPathComponent
                            )
                        )
                        lock.unlock()
                        
                        group.leave()
                    } catch {
                        lock.lock()
                        self.failedItems.append(
                            .init(
                                id: UUID(),
                                url: url,
                                name: url.lastPathComponent,
                                error: .failedToCopyData(error)
                            )
                        )
                        lock.unlock()
                        
                        group.leave()
                    }
                }
                
                group.notify(queue: .global()) {
                    let localItems = self.localItems
                    let remoteItems = self.remoteItems
                    let failedItems = self.failedItems
                    
                    self.localItems = []
                    self.remoteItems = []
                    self.failedItems = []
                    
                    promise(
                        .success(
                            .init(
                                localItems: localItems,
                                remoteItems: remoteItems,
                                failedItems: failedItems
                            )
                        )
                    )
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Load Item Provider
extension RingtoneDataImporter {
    private func loadItemProvider(
        _ itemProvider: NSItemProvider, isRemote: Bool = false,
        completion: @Sendable @escaping (Result<URL, RingtoneDataImporterError>) -> Void
    ) {
        guard let typeIdentifier = itemProvider.registeredTypeIdentifiers.first,
              let utType = UTType(typeIdentifier),
              utType.conforms(to: .movie)
        else {
            completion(.failure(.unsupportedDataFormat))
            return
        }
        
        if isRemote {
            itemProvider.loadFileRepresentation(forTypeIdentifier: typeIdentifier) { url, error in
                if let error = error {
                    completion(.failure(.failedToGetURLFromItemProvider(error)))
                    return
                }
                
                guard let url = url
                else {
                    completion(.failure(.unexpected))
                    return
                }
                
                completion(.success(url))
            }
        } else {
            itemProvider.loadItem(forTypeIdentifier: typeIdentifier) { url, error in
                if let error = error {
                    completion(.failure(.failedToGetURLFromItemProvider(error)))
                    return
                }
                
                guard let url = url as? URL
                else {
                    completion(.failure(.unexpected))
                    return
                }
                
                completion(.success(url))
            }
        }
    }
}

// MARK: - Copy Data
extension RingtoneDataImporter {
    private func copyDataFromUrl(_ url: URL) throws -> URL {
        let accessing = url.startAccessingSecurityScopedResource()
        
        let fileManager = FileManager.default
        let temporaryDirectory = fileManager.temporaryDirectory
        let ouputName = UUID().uuidString + ".\(url.pathExtension)"
        let outputURL = temporaryDirectory
            .appendingPathComponent(ouputName)
        
        do {
            try fileManager.copyItem(at: url, to: outputURL)
            
            if accessing { url.stopAccessingSecurityScopedResource() }
            
            return outputURL
        } catch {
            if accessing { url.stopAccessingSecurityScopedResource() }
            
            throw error
        }
    }
}

// MARK: - Check For Local URLs
extension RingtoneDataImporter {
    private func urlContainsData(_ url: URL) -> Bool {
        let accessing = url.startAccessingSecurityScopedResource()
        
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: url.path) {
            do {
                let fileSize = try fileManager.attributesOfItem(atPath: url.path)[.size] as? NSNumber
                
                if accessing { url.stopAccessingSecurityScopedResource() }
                
                if let size = fileSize, size.intValue > 0 {
                    return true
                } else {
                    return false
                }
            } catch {
                if accessing { url.stopAccessingSecurityScopedResource() }
                
                print("Error checking file attributes: \(error)")
                return false
            }
        } else {
            print("File does not exist.")
            return false
        }
    }
}
