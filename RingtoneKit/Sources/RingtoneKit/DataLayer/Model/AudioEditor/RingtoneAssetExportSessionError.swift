//
//  RingtoneAssetExportSessionError.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 04.03.25.
//

public enum RingtoneAssetExportSessionError: Error {
    case exportFailed(Error)
    case unknown
}
