//
//  RingtoneAudioImportResponder.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 04.03.25.
//

import Combine

public protocol RingtoneAudioImportResponder {
    // MARK: - Properties
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    var audiosPublisher: AnyPublisher<[RingtoneAudio], Never> { get }
    
    // MARK: - Methods
    func retryAll()
    func retryByID(_ id: String)
    func clearAll()
    func clearByID(_ id: String)
}
