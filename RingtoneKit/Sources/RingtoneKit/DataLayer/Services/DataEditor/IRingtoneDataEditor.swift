//
//  IRingtoneDataEditor.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 16.04.25.
//

import Foundation
import Combine

public protocol IRingtoneDataEditor {
    func trimAudio(
        _ audio: RingtoneAudio,
        start: TimeInterval,
        end: TimeInterval,
        fadeIn: TimeInterval,
        fadeOut: TimeInterval,
        mode: RingtoneDataEditorMode
    ) -> AnyPublisher<RingtoneAudio, RingtoneDataEditorError>
    
    func zoomWaveform(
        _ audio: RingtoneAudio,
        start: TimeInterval,
        end: TimeInterval
    ) -> AnyPublisher<RingtoneAudioWaveform, RingtoneDataEditorError>
}
