//
//  IRingtoneDataImporter.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 05.03.25.
//

import Foundation
import Combine

public protocol IRingtoneDataImporter {
    func importDataFromURLs(_ urls: [URL]) -> AnyPublisher<RingtoneDataImporterResult, Never>
    func importDataFromItemProviders(_ itemProviders: [NSItemProvider]) -> AnyPublisher<RingtoneDataImporterResult, Never>
}
