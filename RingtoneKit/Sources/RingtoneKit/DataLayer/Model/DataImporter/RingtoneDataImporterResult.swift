//
//  RingtoneDataImporterResult.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 10.03.25.
//

public struct RingtoneDataImporterResult: Sendable {
    let completeItems: [RingtoneDataImporterCompleteItem]
    let failedItems: [RingtoneDataImporterFailedItem]
}
