//
//  RingtoneDataImporterError.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 05.03.25.
//

import Foundation

public enum RingtoneDataImporterError: Error {
    case unsupportedDataFormat
    case failedToGetURLFromItemProvider(Error)
    case failedToCopyData(Error)
    case unexpected
}
