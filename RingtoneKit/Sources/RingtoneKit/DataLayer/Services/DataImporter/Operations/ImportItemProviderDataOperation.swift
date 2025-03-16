//
//  ImportItemProviderDataOperation.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 15.03.25.
//

import Foundation
import UniformTypeIdentifiers

class ImportItemProviderDataOperation: AsyncOperation, @unchecked Sendable {
    // MARK: - Properties
    private let fileCoordinator = NSFileCoordinator()
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
            
            let temporaryDirectory = self.fileManager.temporaryDirectory
            let ouputName = UUID().uuidString + ".\(url.pathExtension)"
            let outputURL = temporaryDirectory.appendingPathComponent(ouputName)
            
            let accessing = url.startAccessingSecurityScopedResource()
            
            defer {
                if accessing { url.stopAccessingSecurityScopedResource() }
                
                self.state = .finished
            }
            
            do {
                try fileManager.copyItem(at: url, to: outputURL)
                
                completion?(.success(outputURL))
            } catch {
                completion?(.failure(.failedToCopyData(error)))
            }
        }
    }
    
    private func copyDataFromUrl(_ url: URL) throws -> URL {
        let accessing = url.startAccessingSecurityScopedResource()
        defer { if accessing { url.stopAccessingSecurityScopedResource() } }
        
        let fileManager = FileManager.default
        let temporaryDirectory = fileManager.temporaryDirectory
        let ouputName = UUID().uuidString + ".\(url.pathExtension)"
        let outputURL = temporaryDirectory.appendingPathComponent(ouputName)
        
        do {
            try fileManager.copyItem(at: url, to: outputURL)
            return outputURL
        } catch {
            throw error
        }
    }
}
