//
//  RingtoneAudioStoreItem.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 02.03.25.
//

import Foundation

struct RingtoneAudioStoreItem: Sendable {
    public var id: String {
        return title
    }
    
    public var url: URL {
        let fileManager = FileManager.default
        
        let documentsDirectory = fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
        
        return documentsDirectory.appendingPathComponent(
            "tiktok",
            conformingTo: .mp3
        )
    }
    
    let title: String
    let categoryID: String
    let isCreated: Bool
    let isFavorite: Bool
    
    init(
        title: String,
        categoryID: String = "Other",
        isCreated: Bool = false,
        isFavorite: Bool = false
    ) {
        self.title = title
        self.categoryID = categoryID
        self.isCreated = isCreated
        self.isFavorite = isFavorite
    }
}

// MARK: - RingtoneAudio
extension RingtoneAudioStoreItem {
    static func constrcutFromAudio(_ audio: RingtoneAudio) -> RingtoneAudioStoreItem {
        RingtoneAudioStoreItem(
            title: audio.title,
            categoryID: audio.categoryID,
            isCreated: audio.isCreated,
            isFavorite: audio.isFavorite
        )
    }
    
    func convertToAudio() -> RingtoneAudio {
        RingtoneAudio(
            title: self.title,
            categoryID: self.categoryID,
            isPlaying: false,
            isLiked: self.isFavorite
        )
    }
}
