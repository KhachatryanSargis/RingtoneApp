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
    case exportGarageBandProjects(_ urls: [URL])
    case editAudio(_ audio: RingtoneAudio)
}
