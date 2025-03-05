//
//  IRingtoneAudioEditor.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 04.03.25.
//

import Foundation
import Combine

public protocol IRingtoneAudioEditor {
    func convertToAudioRingtone(_ url: URL, suggestedName: String?) -> AnyPublisher<RingtoneAudio, RingtoneAudioEditorError>
}
