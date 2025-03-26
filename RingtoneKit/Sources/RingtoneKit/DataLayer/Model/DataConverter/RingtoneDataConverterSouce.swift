//
//  RingtoneDataConverterSouce.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 14.03.25.
//

import Foundation

enum RingtoneDataConverterSouce {
    case importerItem(RingtoneDataImporterCompleteItem)
    case downloaderItem(RingtoneDataDownloaderCompleteItem)
    
    var id: UUID {
        switch self {
        case .downloaderItem(let item):
            return item.id
        case .importerItem(let item):
            return item.id
        }
    }
    
    var suggestedName: String {
        switch self {
        case .downloaderItem(let item):
            return item.name
        case .importerItem(let item):
            return item.name
        }
    }
}
