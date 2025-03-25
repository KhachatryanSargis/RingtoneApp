//
//  RingtoneAudioImportResponder.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 23.03.25.
//

import Combine

public protocol RingtoneAudioImportResponder {
    // MARK: - Properties
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    var importedAudiosPublisher: AnyPublisher<[RingtoneAudio], Never> { get }
    
    // MARK: - Methods
    func clearFailedRingtoneAudios()
    func retryFailedRingtoneAudio(_ audio: RingtoneAudio)
    func retryFailedRingtoneAudios()
    func cleanFailedRingtoneAudio(_ audio: RingtoneAudio)
}
