//
//  File.swift
//  RingtoneFavoritesAction
//
//  Created by Sargis Khachatryan on 06.04.25.
//

import Foundation

public enum RingtoneFavoritesAction {
    case exportGarageBandProjects(_ urls: [URL])
    case editAudio(_ audio: RingtoneAudio)
}
