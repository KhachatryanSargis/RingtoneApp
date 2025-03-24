//
//  ImportFileDataOpertation.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 16.03.25.
//

import Foundation

final class ImportFileDataOpertation: AsyncOperation, @unchecked Sendable {
    // MARK: - Properties
    private let fileManager = FileManager.default
    private let fileURL: URL
    private let completion: ((Result<URL, RingtoneDataImporterError>) -> Void)?
    
    // MARK: - Methods
    init(fileURL: URL, completion: ((Result<URL, RingtoneDataImporterError>) -> Void)?) {
        self.fileURL = fileURL
        self.completion = completion
    }
    
    override func main() {
        let coordinator = NSFileCoordinator()
        
        var fileCoordinatorError: NSError? = nil
        coordinator.coordinate(readingItemAt: fileURL, error: &fileCoordinatorError) { [weak self] newUrl in
            guard let self = self else { return }
            
            let accessing = newUrl.startAccessingSecurityScopedResource()
            
            defer {
                if accessing { newUrl.stopAccessingSecurityScopedResource() }
                
                self.state = .finished
            }
            
            let temporaryDirectory = fileManager.temporaryDirectory
            let ouputName = UUID().uuidString + ".\(newUrl.pathExtension)"
            let outputURL = temporaryDirectory.appendingPathComponent(ouputName)
            
            do {
                try self.fileManager.copyItem(at: newUrl, to: outputURL)
                
                completion?(.success(outputURL))
            } catch {
                completion?(.failure(.failedToCopyData(error)))
            }
        }
    }
}
