//
//  IRingtoneDataConverter.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 05.03.25.
//

import Foundation
import Combine

public protocol IRingtoneDataConverter {
    func convertDataImporterLocalItems(_ items: [RingtoneDataImporterLocalItem]) -> AnyPublisher<RingtoneDataConverterResult, Never>
}
