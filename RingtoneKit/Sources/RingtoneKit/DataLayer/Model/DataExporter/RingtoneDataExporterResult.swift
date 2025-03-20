//
//  RingtoneDataExporterResult.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 18.03.25.
//

public struct RingtoneDataExporterResult: Sendable {
    let completeItems: [RingtoneDataExporterCompleteItem]
    let failedItems: [RingtoneDataExporterFailedItem]
}
