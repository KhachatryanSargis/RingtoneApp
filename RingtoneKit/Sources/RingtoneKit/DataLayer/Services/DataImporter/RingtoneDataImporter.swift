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
    private var completeItems: [RingtoneDataImporterCompleteItem] = []
    private var failedItems: [RingtoneDataImporterFailedItem] = []
    
    private let queue = OperationQueue()
    private let completeItemLock = NSLock()
    private let failedItemLock = NSLock()
    private var promise: ((Result<RingtoneDataImporterResult, Never>) -> Void)!
    
    // MARK: - Methods
    public init() {
        queue.qualityOfService = .background
        queue.maxConcurrentOperationCount = 10
    }
}

// MARK: - From Gallery
extension RingtoneDataImporter {
    public func importDataFromGallery(_ itemProviders: [NSItemProvider]) -> AnyPublisher<RingtoneDataImporterResult, Never> {
        Deferred {
            Future { [weak self] promise in
                guard let self = self else { return }
                
                self.promise = promise
                
                guard !itemProviders.isEmpty
                else {
                    self.fulfillPromise()
                    return
                }
                
                let fulfillPromiseOperation = BlockOperation()
                fulfillPromiseOperation.completionBlock = {
                    self.fulfillPromise()
                }
                
                for itemProvider in itemProviders {
                    let importItemProviderDataOperation = ImportItemProviderDataOperation(
                        itemProvider: itemProvider
                    ) { result in
                        switch result {
                        case .success(let url):
                            self.createCompleteItem(
                                url: url,
                                source: .gallery(itemProvider)
                            )
                        case .failure(let error):
                            self.createFailedItem(
                                error: .failedToCopyData(error),
                                source: .gallery(itemProvider)
                            )
                        }
                    }
                    
                    fulfillPromiseOperation.addDependency(importItemProviderDataOperation)
                    
                    self.queue.addOperation(importItemProviderDataOperation)
                }
                
                self.queue.addOperation(fulfillPromiseOperation)
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
                
                self.promise = promise
                
                guard !urls.isEmpty
                else {
                    self.fulfillPromise()
                    return
                }
                
                let fulfillPromiseOperation = BlockOperation()
                fulfillPromiseOperation.completionBlock = { [weak self] in
                    guard let self = self else { return }
                    
                    self.fulfillPromise()
                }
                
                for url in urls {
                    let importFileDataOperation = ImportFileDataOpertation(
                        fileURL: url
                    ) { result in
                        switch result {
                        case .success(let url):
                            self.createCompleteItem(
                                url: url,
                                source: .documents(url)
                            )
                        case .failure(let error):
                            self.createFailedItem(
                                error: .failedToCopyData(error),
                                source: .documents(url)
                            )
                        }
                    }
                    
                    fulfillPromiseOperation.addDependency(importFileDataOperation)
                    
                    self.queue.addOperation(importFileDataOperation)
                }
                
                self.queue.addOperation(fulfillPromiseOperation)
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Retry
extension RingtoneDataImporter {
    public func retryFailedItems(_ items: [RingtoneDataImporterFailedItem]) -> AnyPublisher<RingtoneDataImporterResult, Never> {
        fatalError("retryFailedItems not implemented")
    }
}

// MARK: - Create Complete Item
extension RingtoneDataImporter {
    private func createCompleteItem(url: URL, source: RingtoneDataImporterSource) {
        let completeItem = RingtoneDataImporterCompleteItem(
            id: UUID(),
            name: source.suggestedName,
            source: source,
            url: url
        )
        
        completeItemLock.lock()
        completeItems.append(completeItem)
        completeItemLock.unlock()
    }
}

// MARK: - Create Failed Item
extension RingtoneDataImporter {
    private func createFailedItem(error: RingtoneDataImporterError, source: RingtoneDataImporterSource) {
        let failedItem = RingtoneDataImporterFailedItem(
            id: UUID(),
            name: source.suggestedName,
            source: source,
            error: error
        )
        
        failedItemLock.lock()
        failedItems.append(failedItem)
        failedItemLock.unlock()
    }
}

// MARK: - Fulfill Promise
extension RingtoneDataImporter {
    private func fulfillPromise() {
        let completeItems = self.completeItems
        let failedItems = self.failedItems
        
        let result = RingtoneDataImporterResult(
            completeItems: completeItems,
            failedItems: failedItems
        )
        
        promise(.success(result))
    }
}
