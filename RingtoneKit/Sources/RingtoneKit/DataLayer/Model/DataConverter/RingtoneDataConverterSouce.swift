//
//  RingtoneDataConverterSouce.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 14.03.25.
//

import Foundation

enum RingtoneDataConverterSouce {
    case importerItem(RingtoneDataImporterCompleteItem)
    // TODO: Create RingtoneDataDownlaoder and it's Item.
    case downloaderItem
    
    var id: UUID {
        switch self {
        case .downloaderItem:
            return UUID()
        case .importerItem(let item):
            return item.id
        }
    }
    
    var suggestedName: String {
        switch self {
        case .downloaderItem:
            return "My Ringtone"
        case .importerItem(let item):
            return item.name
        }
    }
}
