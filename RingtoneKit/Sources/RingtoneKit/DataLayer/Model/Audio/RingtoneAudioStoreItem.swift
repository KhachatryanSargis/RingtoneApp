//
//  RingtoneAudioStoreItem.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 02.03.25.
//

import Foundation

struct RingtoneAudioStoreItem: Sendable {
    public static var dummyURL: URL {
        let fileManager = FileManager.default
        
        let documentsDirectory = fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
        
        return documentsDirectory
            .appendingPathComponent("Ringtones", isDirectory: true)
            .appendingPathComponent("tiktok.band")
    }
    
    let id: String
    let title: String
    let description: String
    let categoryID: String
    let isCreated: Bool
    let isFavorite: Bool
    let url: URL
    let waveformURL: URL
    
    init(
        id: String = UUID().uuidString,
        title: String,
        description: String,
        categoryID: String = "Other",
        isCreated: Bool = false,
        isFavorite: Bool = false,
        url: URL = dummyURL,
        waveformURL: URL = dummyURL
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.categoryID = categoryID
        self.isCreated = isCreated
        self.isFavorite = isFavorite
        self.url = url
        self.waveformURL = waveformURL
    }
}

// MARK: - RingtoneAudio
extension RingtoneAudioStoreItem {
    static func constrcutFromAudio(_ audio: RingtoneAudio) -> RingtoneAudioStoreItem {
        RingtoneAudioStoreItem(
            id: audio.id,
            title: audio.title,
            description: audio.desciption,
            categoryID: audio.categoryID,
            isCreated: audio.isCreated,
            isFavorite: audio.isFavorite,
            waveformURL: audio.waveformURL
        )
    }
    
    func convertToAudio() -> RingtoneAudio {
        RingtoneAudio(
            id: self.id,
            title: self.title,
            desciption: self.description,
            categoryID: self.categoryID,
            isPlaying: false,
            isLiked: self.isFavorite,
            url: self.url,
            waveformURL: self.waveformURL
        )
    }
}
