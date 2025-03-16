//
//  RingtoneDataImporterSource.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 11.03.25.
//

import Foundation
import Photos

// TODO: Come up with a way to avoid using @unchecked Sendable.
enum RingtoneDataImporterSource: @unchecked Sendable {
    case gallery(NSItemProvider)
    case documents(URL)
    
    var suggestedName: String {
        switch self {
        case .gallery(let itemProvider):
            return itemProvider.suggestedName ?? "My Ringtone"
        case .documents(let url):
            return url.lastPathComponent.replacingOccurrences(
                of: ".\(url.pathExtension)",
                with: ""
            )
        }
    }
}
