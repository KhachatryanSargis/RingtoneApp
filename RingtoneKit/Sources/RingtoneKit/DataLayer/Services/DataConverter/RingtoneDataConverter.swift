//
//  RingtoneDataConverter.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 04.03.25.
//

import AVFoundation
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
                let convertDataImporterItemOperation = ConvertDataImporterItemOperation(
                    item: item
                ) { result in
                    switch result {
                    case .success(let response):
                        self.createCompleteItem(
                            item: item,
                            url: response.url,
                            asset: response.asset
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
}

// MARK: - Create Complete Item
extension RingtoneDataConverter {
    private func createCompleteItem(item: RingtoneDataImporterCompleteItem, url: URL, asset: AVAsset) {
        let description = getAssetDurationAndSize(asset, at: url)
        
        let completeItem = RingtoneDataConverterCompleteItem(
            description: description,
            souce: .importerItem(item),
            url: url
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

// MARK: - Asset Duration and Size
extension RingtoneDataConverter {
    func getAssetDurationAndSize(_ asset: AVAsset, at url: URL) -> String {
        let durationInSeconds = asset.duration.seconds
        
        let minutes = Int(durationInSeconds) / 60
        let seconds = Int(durationInSeconds) % 60
        let durationFormatted = String(format: "%02d:%02d", minutes, seconds)
        
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let fileSize = fileAttributes[.size] as? NSNumber {
                let fileSizeInMB = fileSize.doubleValue / (1024 * 1024)
                
                let sizeFormatted: String
                if fileSizeInMB < 1 {
                    let fileSizeInKB = fileSize.doubleValue / 1024
                    sizeFormatted = String(format: "%.1f KB", fileSizeInKB)
                } else {
                    sizeFormatted = String(format: "%.1f MB", fileSizeInMB)
                }
                
                return "\(durationFormatted) • \(sizeFormatted)"
            } else {
                return "\(durationFormatted) • Unknown Size"
            }
        } catch {
            return "\(durationFormatted) • Unknown Size"
        }
    }
}
