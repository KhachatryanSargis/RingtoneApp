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
    private var urls: [URL] = []
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
                        
                        let accessing = url.startAccessingSecurityScopedResource()
                        
                        let fileManager = FileManager.default
                        let temporaryDirectory = fileManager.temporaryDirectory
                        let ouputName = UUID().uuidString + ".\(url.pathExtension)"
                        let outputURL = temporaryDirectory
                            .appendingPathComponent(ouputName)
                        
                        do {
                            try fileManager.copyItem(at: url, to: outputURL)
                            
                            if accessing { url.stopAccessingSecurityScopedResource() }
                            
                            urlLock.lock()
                            self.urls.append(outputURL)
                            urlLock.unlock()
                            
                            group.leave()
                        } catch {
                            if accessing { url.stopAccessingSecurityScopedResource() }
                            
                            errorLock.lock()
                            self.errors.append(.failedToReadDataFromURL(url))
                            errorLock.unlock()
                            
                            group.leave()
                        }
                    }
                }
                
                group.notify(queue: .global()) {
                    let urls = self.urls
                    let errors = self.errors
                    
                    self.urls = []
                    self.errors = []
                    
                    promise(.success(.init(urls: urls, errors: errors)))
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
                
                let group = DispatchGroup()
                let urlLock = NSLock()
                let errorLock = NSLock()
                
                for url in urls {
                    group.enter()
                    
                    let accessing = url.startAccessingSecurityScopedResource()
                    
                    let fileManager = FileManager.default
                    let temporaryDirectory = fileManager.temporaryDirectory
                    let ouputName = UUID().uuidString + ".\(url.pathExtension)"
                    let outputURL = temporaryDirectory
                        .appendingPathComponent(ouputName)
                    
                    do {
                        try fileManager.copyItem(at: url, to: outputURL)
                        
                        if accessing { url.stopAccessingSecurityScopedResource() }
                        
                        urlLock.lock()
                        self.urls.append(outputURL)
                        urlLock.unlock()
                        
                        group.leave()
                    } catch {
                        if accessing { url.stopAccessingSecurityScopedResource() }
                        
                        errorLock.lock()
                        self.errors.append(.failedToReadDataFromURL(url))
                        errorLock.unlock()
                        
                        group.leave()
                    }
                }
                
                group.notify(queue: .global()) {
                    let urls = self.urls
                    let errors = self.errors
                    
                    self.urls = []
                    self.errors = []
                    
                    promise(.success(.init(urls: urls, errors: errors)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
