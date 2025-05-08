//
//  RingtoneDataConverter.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 04.03.25.
//

import Foundation
import Combine

public final class RingtoneDataConverter: IRingtoneDataConverter, @unchecked Sendable {
    // MARK: - Properties
    private var completeItems: [RingtoneDataConverterCompleteItem] = []
    private var failedItems: [RingtoneDataConverterFailedItem] = []
    
    private let queue = OperationQueue()
    private let completeItemLock = NSLock()
    private let failedItemLock = NSLock()
    private var promise: ((Result<RingtoneDataConverterResult, Never>) -> Void)!
    
    // MARK: - Methods
    public init() {
        queue.underlyingQueue = .global(qos: .utility)
        queue.maxConcurrentOperationCount = 10
    }
}

// MARK: - Convert
extension RingtoneDataConverter {
    public func convertDataImporterCompleteItems(_ items: [RingtoneDataImporterCompleteItem]) -> AnyPublisher<RingtoneDataConverterResult, Never> {
        Future { [weak self] promise in
            guard let self = self else { return }
            
            self.promise = promise
            
            guard !items.isEmpty
            else {
                self.fulfillPromise()
                return
            }
            
            var operations: [Operation] = []
            
            let fulfillPromiseOperation = BlockOperation()
            fulfillPromiseOperation.completionBlock = {
                self.fulfillPromise()
            }
            
            operations.append(fulfillPromiseOperation)
            
            for item in items {
                let convertDataImporterItemOperation = ConvertCompatibleItemOperation(
                    item: item
                ) { result in
                    switch result {
                    case .success(let response):
                        self.createCompleteItem(
                            item: item,
                            url: response.url,
                            waveformURL: response.waveformURL,
                            duration: response.duration
                        )
                    case .failure(let error):
                        self.createFailedItem(
                            item: item,
                            error: error
                        )
                    }
                }
                
                fulfillPromiseOperation.addDependency(convertDataImporterItemOperation)
                operations.append(convertDataImporterItemOperation)
            }
            
            self.queue.addOperations(operations, waitUntilFinished: false)
        }
        .subscribe(on: queue)
        .eraseToAnyPublisher()
    }
    
    public func convertDataDownloaderCompleteItems(_ items: [RingtoneDataDownloaderCompleteItem]) -> AnyPublisher<RingtoneDataConverterResult, Never> {
        Future { [weak self] promise in
            guard let self = self else { return }
            
            self.promise = promise
            
            guard !items.isEmpty
            else {
                self.fulfillPromise()
                return
            }
            
            var operations: [Operation] = []
            
            let fulfillPromiseOperation = BlockOperation()
            fulfillPromiseOperation.completionBlock = {
                self.fulfillPromise()
            }
            
            operations.append(fulfillPromiseOperation)
            
            for item in items {
                let convertDataDownloaderItemOperation = ConvertCompatibleItemOperation(
                    item: item
                ) { result in
                    switch result {
                    case .success(let response):
                        self.createCompleteItem(
                            item: item,
                            url: response.url,
                            waveformURL: response.waveformURL,
                            duration: response.duration
                        )
                    case .failure(let error):
                        self.createFailedItem(
                            item: item,
                            error: error
                        )
                    }
                }
                
                fulfillPromiseOperation.addDependency(convertDataDownloaderItemOperation)
                operations.append(convertDataDownloaderItemOperation)
            }
            
            self.queue.addOperations(operations, waitUntilFinished: false)
        }
        .subscribe(on: queue)
        .eraseToAnyPublisher()
    }
}

// MARK: - Create Complete Item
extension RingtoneDataConverter {
    private func createCompleteItem(item: RingtoneDataImporterCompleteItem, url: URL, waveformURL: URL, duration: TimeInterval) {
        let formattedDuration = duration.shortFormatted()
        let formattedSize = url.getFormattedFileSize()
        let description = "\(formattedDuration) • \(formattedSize)"
        
        let completeItem = RingtoneDataConverterCompleteItem(
            description: description,
            souce: .importerItem(item),
            url: url,
            waveformURL: waveformURL
        )
        
        completeItemLock.lock()
        completeItems.append(completeItem)
        completeItemLock.unlock()
    }
    
    private func createCompleteItem(item: RingtoneDataDownloaderCompleteItem, url: URL, waveformURL: URL, duration: TimeInterval) {
        let formattedDuration = duration.shortFormatted()
        let formattedSize = url.getFormattedFileSize()
        let description = "\(formattedDuration) • \(formattedSize)"
        
        let completeItem = RingtoneDataConverterCompleteItem(
            description: description,
            souce: .downloaderItem(item),
            url: url,
            waveformURL: waveformURL
        )
        
        completeItemLock.lock()
        completeItems.append(completeItem)
        completeItemLock.unlock()
    }
}

// MARK: - Create Failed Item
extension RingtoneDataConverter {
    private func createFailedItem(item: RingtoneDataImporterCompleteItem, error: RingtoneDataConverterError) {
        let failedItem = RingtoneDataConverterFailedItem(
            souce: .importerItem(item),
            error: error
        )
        
        failedItemLock.lock()
        failedItems.append(failedItem)
        failedItemLock.unlock()
    }
    
    private func createFailedItem(item: RingtoneDataDownloaderCompleteItem, error: RingtoneDataConverterError) {
        let failedItem = RingtoneDataConverterFailedItem(
            souce: .downloaderItem(item),
            error: error
        )
        
        failedItemLock.lock()
        failedItems.append(failedItem)
        failedItemLock.unlock()
    }
}

// MARK: - Fulfill Promise
extension RingtoneDataConverter {
    private func fulfillPromise() {
        let completeItems = self.completeItems
        let failedItems = self.failedItems
        
        let result = RingtoneDataConverterResult(
            completeItems: completeItems,
            failedItems: failedItems
        )
        
        promise(.success(result))
    }
}
