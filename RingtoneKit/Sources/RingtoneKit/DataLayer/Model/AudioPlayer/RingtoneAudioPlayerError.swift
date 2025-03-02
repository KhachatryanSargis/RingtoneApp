//
//  RingtoneAudioPlayerError.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 02.03.25.
//

public enum RingtoneAudioPlayerError: Error {
    case failedToCreatePlayer(Error)
    case failedToStartPlaying
}
