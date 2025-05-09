//
//  RingtoneFavoritesAction.swift
//  RingtoneFavoritesAction
//
//  Created by Sargis Khachatryan on 06.04.25.
//

import Foundation

public enum RingtoneFavoritesAction {
    case editAudio(_ audio: RingtoneAudio)
    case exportGarageBandProject(_ url: URL, _ audio: RingtoneAudio)
    case exportAudios(_ audios: [RingtoneAudio])
    case showUsageTutorial
}
