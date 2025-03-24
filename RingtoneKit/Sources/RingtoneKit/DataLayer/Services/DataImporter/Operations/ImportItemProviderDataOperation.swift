//
//  ImportItemProviderDataOperation.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 15.03.25.
//

import Foundation
import UniformTypeIdentifiers

final class ImportItemProviderDataOperation: AsyncOperation, @unchecked Sendable {
    // MARK: - Properties
    private let fileManager = FileManager.default
    private var progress: Progress?
    private let itemProvider: NSItemProvider
    private let completion: ((Result<URL, RingtoneDataImporterError>) -> Void)?
    
    // MARK: - Methods
    init(
        itemProvider: NSItemProvider,
        completion: ((Result<URL, RingtoneDataImporterError>) -> Void)? = nil
    ) {
        self.itemProvider = itemProvider
        self.completion = completion
    }
    
    override func main() {
        guard let typeIdentifier = itemProvider.registeredTypeIdentifiers.first,
              let utType = UTType(typeIdentifier),
              utType.conforms(to: .movie) else {
            
            completion?(.failure(.unsupportedDataFormat))
            
            state = .finished
            return
        }
        
        progress = itemProvider.loadFileRepresentation(forTypeIdentifier: typeIdentifier) { [weak self] url, error in
            guard let self = self else { return }
            
            self.progress = nil
            
            if let error = error {
                completion?(.failure(.failedToGetURLFromItemProvider(error)))
                
                self.state = .finished
                return
            }
            
            guard let url = url else {
                completion?(.failure(.unexpected))
                
                self.state = .finished
                return
            }
            
            let coordinator = NSFileCoordinator()
            
            var fileCoordinatorError: NSError? = nil
            coordinator.coordinate(readingItemAt: url, error: &fileCoordinatorError) { newUrl in
                do {
                    let temporaryDirectory = self.fileManager.temporaryDirectory
                    let ouputName = UUID().uuidString + ".\(newUrl.pathExtension)"
                    let outputURL = temporaryDirectory.appendingPathComponent(ouputName)
                    
                    try self.fileManager.copyItem(at: newUrl, to: outputURL)
                    
                    self.completion?(.success(outputURL))
                    
                    self.state = .finished
                } catch {
                    self.completion?(.failure(.failedToCopyData(error)))
                    
                    self.state = .finished
                }
            }
        }
    }
}
