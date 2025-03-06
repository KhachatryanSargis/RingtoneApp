//
//  IRingtoneDataConverter.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 05.03.25.
//

import Foundation
import Combine

public protocol IRingtoneDataConverter {
    func convertToRingtoneAudios(_ urls: [URL]) -> AnyPublisher<RingtoneDataConverterResult, Never>
}
