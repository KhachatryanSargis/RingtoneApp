//
//  IRingtoneDataImporter.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 05.03.25.
//

import Foundation
import Combine

public protocol IRingtoneDataImporter {
    func importDataFromGallery(_ itemProviders: [NSItemProvider]) -> AnyPublisher<RingtoneDataImporterResult, Never>
    func importDataFromDocuments(_ urls: [URL]) -> AnyPublisher<RingtoneDataImporterResult, Never>
    func retryFailedItems(_ items: [RingtoneDataImporterFailedItem]) -> AnyPublisher<RingtoneDataImporterResult, Never>
}
