//
//  RingtoneCreatedAction.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 03.03.25.
//

public enum RingtoneCreatedAction {
    case importAudio
    case export(_ audio: RingtoneAudio)
    case edit(_ audio: RingtoneAudio)
}
