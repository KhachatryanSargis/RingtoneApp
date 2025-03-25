//
//  RingtoneAudioSelectionResponder.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 23.03.25.
//

public protocol RingtoneAudioSelectionResponder {
    func enableSelection()
    func disableSelection()
    func toggleRingtoneAudioSelectionStatus(_ audio: RingtoneAudio)
    func selectAllRingtoneAudios()
    func deselectAllRingtoneAudios()
}
