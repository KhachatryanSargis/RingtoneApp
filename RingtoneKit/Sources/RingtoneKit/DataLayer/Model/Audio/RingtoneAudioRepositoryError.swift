//
//  RingtoneAudioRepositoryError.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 27.02.25.
//

public enum RingtoneAudioRepositoryError: Error {
    case getRingtoneAudiosInCategory
    case getFavoriteRingtoneAudios
    case getCreatedRingtoneAudios
    case addRingtoneAudioToFavorites
    case removeRingtoneAudioFromFavorites
}
