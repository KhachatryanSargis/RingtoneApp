//
//  RingtoneAudioPlayerStatus.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 02.03.25.
//

public enum RingtoneAudioPlayerStatus {
    case failedToInitialize(Error)
    case failedToPlay(audioID: String)
    case startedPlaying(audioID: String)
    case pausedPlaying(audioID: String)
    case finishedPlaying(audioID: String)
}
