//
//  RingtoneRemoteDataImporter.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 09.03.25.
//

import Foundation
import Combine
import UniformTypeIdentifiers

public final class RingtoneRemoteDataImporter: IRingtoneDataImporter, @unchecked Sendable {
    // MARK: - Properties
    private var items: [RingtoneDataImporterItem] = []
    
    // MARK: - Methods
    public init() {}
    
    public func importDataFromItemProviders(_ itemProviders: [NSItemProvider]) -> AnyPublisher<[RingtoneDataImporterItem], Never> {
        Deferred {
            Future { [weak self] promise in
                guard let self = self else { return }
                
                guard !itemProviders.isEmpty
                else {
                    promise(.success([]))
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
                            do {
                                let outputURL = try self.copyDataFromUrl(url)
                                
                                lock.lock()
                                self.items.append(
                                    .init(
                                        id: UUID(),
                                        name: suggestedName ?? "My Ringtone",
                                        result: .success(outputURL),
                                        isRemote: false
                                    )
                                )
                                lock.unlock()
                                
                                group.leave()
                            } catch {
                                lock.lock()
                                self.items.append(
                                    .init(
                                        id: UUID(),
                                        name: suggestedName ?? "My Ringtone",
                                        result: .failure(.failedToCopyData(error)),
                                        isRemote: false
                                    )
                                )
                                lock.unlock()
                                
                                group.leave()
                            }
                        case .failure(let error):
                            lock.lock()
                            self.items.append(
                                .init(
                                    id: UUID(),
                                    name: suggestedName ?? "My Ringtone",
                                    result: .failure(error),
                                    isRemote: false
                                )
                            )
                            lock.unlock()
                            
                            group.leave()
                        }
                    }
                }
                
                group.notify(queue: .global()) {
                    let items = self.items
                    self.items = []
                    
                    promise(.success(items))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func importDataFromURLs(_ urls: [URL]) -> AnyPublisher<[RingtoneDataImporterItem], Never> {
        Deferred {
            Future { [weak self] promise in
                guard let self = self else { return }
                
                guard !urls.isEmpty
                else {
                    promise(.success([]))
                    return
                }
                
                let group = DispatchGroup()
                let lock = NSLock()
                
                for url in urls {
                    group.enter()
                    
                    do {
                        let outputURL = try self.copyDataFromUrl(url)
                        
                        lock.lock()
                        self.items.append(
                            .init(
                                id: UUID(),
                                name: url.lastPathComponent,
                                result: .success(outputURL),
                                isRemote: false
                            )
                        )
                        lock.unlock()
                        
                        group.leave()
                    } catch {
                        lock.lock()
                        self.items.append(
                            .init(
                                id: UUID(),
                                name: url.lastPathComponent,
                                result: .failure(.failedToCopyData(error)),
                                isRemote: false
                            )
                        )
                        lock.unlock()
                        
                        group.leave()
                    }
                }
                
                group.notify(queue: .global()) {
                    let items = self.items
                    self.items = []
                    promise(.success(.init(items)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Load Item Provider
extension RingtoneRemoteDataImporter {
    private func loadItemProvider(
        _ itemProvider: NSItemProvider,
        completion: @Sendable @escaping (Result<URL, RingtoneDataImporterError>) -> Void
    ) {
        guard let typeIdentifier = itemProvider.registeredTypeIdentifiers.first,
              let utType = UTType(typeIdentifier),
              utType.conforms(to: .movie)
        else {
            completion(.failure(.unsupportedDataFormat))
            return
        }
        
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
    }
}

// MARK: - Copy Data
extension RingtoneRemoteDataImporter {
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
extension RingtoneRemoteDataImporter {
    private func urlContainsData(_ url: URL) -> Bool {
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: url.path) {
            do {
                let fileSize = try fileManager.attributesOfItem(atPath: url.path)[.size] as? NSNumber
                if let size = fileSize, size.intValue > 0 {
                    return true
                } else {
                    return false
                }
            } catch {
                print("Error checking file attributes: \(error)")
                return false
            }
        } else {
            print("File does not exist.")
            return false
        }
    }
}
