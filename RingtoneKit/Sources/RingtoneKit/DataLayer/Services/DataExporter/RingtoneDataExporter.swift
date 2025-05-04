//
//  RingtoneDataExporter.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 17.03.25.
//

import Foundation
import Combine

final public class RingtoneDataExporter: IRingtoneDataExporter, @unchecked Sendable {
    // MARK: - Properties
    private var completeItems: [RingtoneDataExporterCompleteItem] = []
    private var failedItems: [RingtoneDataExporterFailedItem] = []
    
    private let queue = OperationQueue()
    private let completeItemLock = NSLock()
    private let failedItemLock = NSLock()
    private var promise: ((Result<RingtoneDataExporterResult, Never>) -> Void)!
    
    // MARK: - Methods
    public init() {
        queue.qualityOfService = .background
        queue.maxConcurrentOperationCount = 10
    }
}

// MARK: - Create Garage Band Project
extension RingtoneDataExporter {
    public func createGarageBandProject(from audio: RingtoneAudio) -> AnyPublisher<URL, RingtoneDataExporterError> {
        Future { promise in
            let createGarageBandProjectOperation = CreateGarageBandProjectOperation(
                audio: audio
            ) { result in
                switch result {
                case .success(let url):
                    promise(.success(url))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
            
            self.queue.addOperation(createGarageBandProjectOperation)
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Export
extension RingtoneDataExporter {
    public func exportRingtoneAudios(_ audios: [RingtoneAudio]) -> AnyPublisher<RingtoneDataExporterResult, Never> {
        Future { [weak self] promise in
            guard let self = self else { return }
            
            self.promise = promise
            
            guard !audios.isEmpty
            else {
                self.fulfillPromise()
                return
            }
            
            var operations: [Operation] = []
            
            let fulfillPromiseOperation = BlockOperation()
            fulfillPromiseOperation.completionBlock = { [weak self] in
                guard let self = self else { return }
                
                self.fulfillPromise()
                return
            }
            
            operations.append(fulfillPromiseOperation)
            
            for audio in audios {
                let createGarageBandProjectOperation = CreateGarageBandProjectOperation(
                    audio: audio
                ) { result in
                    switch result {
                    case .success(let url):
                        self.createCompleteItem(
                            source: audio,
                            url: url
                        )
                    case .failure(let error):
                        self.createFailedItem(
                            source: audio,
                            error: error
                        )
                    }
                }
                
                fulfillPromiseOperation.addDependency(createGarageBandProjectOperation)
                operations.append(createGarageBandProjectOperation)
            }
            
            self.queue.addOperations(operations, waitUntilFinished: false)
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Create Complete Item
extension RingtoneDataExporter {
    private func createCompleteItem(
        source: RingtoneAudio,
        url: URL
    ) {
        let item = RingtoneDataExporterCompleteItem(
            source: source,
            url: url
        )
        
        completeItemLock.lock()
        completeItems.append(item)
        completeItemLock.unlock()
    }
}

// MARK: - Create Failed Item
extension RingtoneDataExporter {
    private func createFailedItem(
        source: RingtoneAudio,
        error: RingtoneDataExporterError
    ) {
        let item = RingtoneDataExporterFailedItem(
            source: source,
            error: error
        )
        
        failedItemLock.lock()
        failedItems.append(item)
        failedItemLock.unlock()
    }
}

// MARK: - Fulfill Promise
extension RingtoneDataExporter {
    private func fulfillPromise() {
        let completeItems = self.completeItems
        let failedItems = self.failedItems
        
        let result = RingtoneDataExporterResult(
            completeItems: completeItems,
            failedItems: failedItems
        )
        
        promise(.success(result))
    }
}
