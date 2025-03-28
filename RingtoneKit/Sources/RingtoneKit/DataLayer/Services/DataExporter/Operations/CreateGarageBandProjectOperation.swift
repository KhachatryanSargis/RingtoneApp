//
//  CreateGarageBandProjectOperation.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 17.03.25.
//

import Foundation
import AVFoundation

final class CreateGarageBandProjectOperation: AsyncOperation, @unchecked Sendable {
    // MARK: - Properties
    private let fileManager = FileManager.default
    
    private let audio: RingtoneAudio
    private let completion: ((Result<URL, RingtoneDataExporterError>) -> Void)?
    
    // MARK: - Methods
    init(
        audio: RingtoneAudio,
        completion: ((Result<URL, RingtoneDataExporterError>) -> Void)?
    ) {
        self.audio = audio
        self.completion = completion
    }
    
    override func main() {
        defer { state = .finished }
        
        let projectFolder: URL
        
        do {
            projectFolder = try self.createProjectStructure()
        } catch {
            self.completion?(.failure(.failedToCreateProjectStructure(error)))
            return
        }
        
        do {
            try self.copyProjectDataFile(projectFolder)
        } catch {
            self.completion?(.failure(.failedToCopyProjectDataFile(error)))
            return
        }
        
        do {
            try self.copyAudioFile(projectFolder)
            
            self.completion?(.success(projectFolder))
        } catch {
            self.completion?(.failure(.failedToCopyAudioFile(error)))
        }
    }
    
    func createProjectStructure() throws -> URL {
        var rootFolderURL = fileManager.temporaryDirectory.appendingPathComponent(audio.title)
        
        var index = 1
        
        while fileManager.fileExists(atPath: rootFolderURL.path) {
            rootFolderURL = fileManager.temporaryDirectory.appendingPathComponent("\(audio.title)_\(index)")
            
            index += 1
        }
        
        let projectFolderURL = rootFolderURL.appendingPathComponent("\(audio.title).band")
        let mediaFolderURL = projectFolderURL.appendingPathComponent("Media")
        let outputFolderURL = projectFolderURL.appendingPathComponent("Output")
        
        try fileManager.createDirectory(at: rootFolderURL, withIntermediateDirectories: true, attributes: nil)
        try fileManager.createDirectory(at: projectFolderURL, withIntermediateDirectories: true, attributes: nil)
        try fileManager.createDirectory(at: mediaFolderURL, withIntermediateDirectories: true, attributes: nil)
        try fileManager.createDirectory(at: outputFolderURL, withIntermediateDirectories: true, attributes: nil)
        
        return projectFolderURL
    }
    
    private func copyProjectDataFile(_ projectURL: URL) throws {
        let projectData_SourceURL = Bundle.main.url(
            forResource: "projectData",
            withExtension: nil
        )!
        
        let projectData_DestinationURL = projectURL
            .appendingPathComponent("projectData")
        
        try fileManager.copyItem(
            at: projectData_SourceURL,
            to: projectData_DestinationURL
        )
    }
    
    private func copyAudioFile(_ projectURL: URL) throws {
        let destinationURL = projectURL
            .appendingPathComponent("Media")
            .appendingPathComponent("ringtone")
            .appendingPathExtension(audio.url.pathExtension)
        
        try fileManager.copyItem(at: audio.url, to: destinationURL)
    }
}
