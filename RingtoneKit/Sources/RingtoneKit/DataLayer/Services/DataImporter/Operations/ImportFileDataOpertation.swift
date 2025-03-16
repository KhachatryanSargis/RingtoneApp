//
//  ImportFileDataOpertation.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 16.03.25.
//

import Foundation

class ImportFileDataOpertation: AsyncOperation, @unchecked Sendable {
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
        let accessing = fileURL.startAccessingSecurityScopedResource()
        defer {
            if accessing { fileURL.stopAccessingSecurityScopedResource() }
            
            self.state = .finished
        }
        
        let temporaryDirectory = fileManager.temporaryDirectory
        let ouputName = UUID().uuidString + ".\(fileURL.pathExtension)"
        let outputURL = temporaryDirectory
            .appendingPathComponent(ouputName)
        
        do {
            try self.fileManager.copyItem(at: fileURL, to: outputURL)
            
            completion?(.success(outputURL))
        } catch {
            completion?(.failure(.failedToCopyData(error)))
        }
    }
}
