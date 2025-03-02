//
//  File.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 26.02.25.
//

import Foundation

public struct RingtoneAudio: Equatable, Hashable, Sendable {
    public var id: String {
        return title
    }
    
    public var url: URL {
        let fileManager = FileManager.default
        
        let documentsDirectory = fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
        
        return documentsDirectory.appendingPathComponent("tiktok.m4a")
    }
    
    public let title: String
    public let categoryID: String
    public let isCreated: Bool
    public let isPlaying: Bool
    public let isFavorite: Bool
    
    public init(
        title: String,
        categoryID: String = "Other",
        isCreated: Bool = false,
        isPlaying: Bool = false,
        isLiked: Bool = false
    ) {
        self.title = title
        self.categoryID = categoryID
        self.isCreated = isCreated
        self.isPlaying = isPlaying
        self.isFavorite = isLiked
    }
}

// MARK: - Like, Unlike
extension RingtoneAudio {
    public func liked() -> RingtoneAudio {
        RingtoneAudio(
            title: self.title,
            categoryID: self.categoryID,
            isCreated: self.isCreated,
            isPlaying: self.isPlaying,
            isLiked: true
        )
    }
    
    public func unliked() -> RingtoneAudio {
        RingtoneAudio(
            title: self.title,
            categoryID: self.categoryID,
            isCreated: self.isCreated,
            isPlaying: self.isPlaying,
            isLiked: false
        )
    }
}

// MARK: - Play, Pause
extension RingtoneAudio {
    public func played() -> RingtoneAudio {
        RingtoneAudio(
            title: self.title,
            categoryID: self.categoryID,
            isCreated: self.isCreated,
            isPlaying: true,
            isLiked: self.isFavorite
        )
    }
    
    public func paused() -> RingtoneAudio {
        RingtoneAudio(
            title: self.title,
            categoryID: self.categoryID,
            isCreated: self.isCreated,
            isPlaying: false,
            isLiked: self.isFavorite
        )
    }
}

// MARK: - Empty
extension RingtoneAudio {
    public static var empty: RingtoneAudio {
        .init(
            title: "",
            categoryID: "",
            isCreated: false,
            isPlaying: false,
            isLiked: false
        )
    }
}
