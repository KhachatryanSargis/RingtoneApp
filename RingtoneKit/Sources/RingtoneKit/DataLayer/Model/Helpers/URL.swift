//
//  URL.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 24.04.25.
//

import Foundation

extension URL {
    func getFileSize() -> Double? {
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: path)
            if let fileSize = fileAttributes[.size] as? NSNumber {
                return fileSize.doubleValue
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    func getFormattedFileSize() -> String {
        guard let fileSize = getFileSize()
        else { return "Unknown Size" }
        
        let fileSizeInMB = fileSize / (1024 * 1024)
        
        let formattedFileSize: String
        
        if fileSizeInMB < 1 {
            let fileSizeInKB = fileSize / 1024
            formattedFileSize = String(format: "%.0f KB", fileSizeInKB)
        } else {
            formattedFileSize = String(format: "%.1f MB", fileSizeInMB)
        }
        
        return formattedFileSize
    }
}
