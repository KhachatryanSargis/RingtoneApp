//
//  RingtoneCreatedAction.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 03.03.25.
//

import Foundation

public enum RingtoneCreatedAction {
    case importAudio
    case importAudioFromGallery
    case importAudioFromFiles
    case importAudioFromURL
    case editAudio(_ audio: RingtoneAudio)
    case exportGarageBandProject(_ url: URL, _ audio: RingtoneAudio)
    case exportAudios(_ audios: [RingtoneAudio])
    case showUsageTutorial
}
