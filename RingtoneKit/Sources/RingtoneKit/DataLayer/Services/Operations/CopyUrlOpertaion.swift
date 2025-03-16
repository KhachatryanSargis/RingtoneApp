//
//  CopyUrlOpertaion.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 16.03.25.
//

import Foundation

class CopyUrlOpertaion: AsyncOperation, @unchecked Sendable {
    // MARK: - Properties
    private let fileCoordinator = NSFileCoordinator()
    private let url: URL
    private let queue: OperationQueue
    private let completion: (Result<URL, Error>) -> Void
    private let fileManager = FileManager.default
    
    init(
        url: URL,
        queue: OperationQueue,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        self.url = url
        self.queue = queue
        self.completion = completion
    }
    
    // MARK: - Methods
    override func main() {
        let temporaryDirectory = fileManager.temporaryDirectory
        let ouputName = UUID().uuidString + ".\(url.pathExtension)"
        let outputURL = temporaryDirectory
            .appendingPathComponent(ouputName)
        
        fileCoordinator.coordinate(
            with: [.readingIntent(with: url), .writingIntent(with: outputURL)],
            queue: queue
        ) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            do {
                try self.fileManager.copyItem(at: url, to: outputURL)
                
                completion(.success(outputURL))
            } catch {
                completion(.failure(error))
            }
            
            self.state = .finished
        }
    }
}
