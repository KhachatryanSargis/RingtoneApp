//
//  RingtoneDiscoverViewModelAction.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 21.03.25.
//

import Foundation

public enum RingtoneDiscoverAction {
    case exportGarageBandProjects(_ urls: [URL])
    case editAudio(_ audio: RingtoneAudio)
}
