//
//  FileManager.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 24.04.25.
//

import Foundation

extension FileManager {
    var ringtonesDirectory: URL {
        guard let documentDirectoryURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            fatalError("Documents directory not found.")
        }
        
        let ringtonesDirectory = documentDirectoryURL.appendingPathComponent("Ringtones", isDirectory: true)
        
        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: ringtonesDirectory.path, isDirectory: &isDirectory)
        
        if exists && isDirectory.boolValue {
            return ringtonesDirectory
        } else {
            do {
                try FileManager.default.createDirectory(at: ringtonesDirectory, withIntermediateDirectories: true)
                
                return ringtonesDirectory
            } catch {
                fatalError("Failed to create ringtones directory.")
            }
        }
    }
}
