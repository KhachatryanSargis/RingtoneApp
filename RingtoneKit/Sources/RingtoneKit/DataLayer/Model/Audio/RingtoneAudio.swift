//
//  File.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 26.02.25.
//

import Foundation

public struct RingtoneAudio: Identifiable, Equatable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let categoryID: String
    public let isCreated: Bool
    public let isPlaying: Bool
    public let isFavorite: Bool
    public let url: URL
    
    public init(
        id: String,
        title: String,
        categoryID: String = "Other",
        isCreated: Bool = false,
        isPlaying: Bool = false,
        isLiked: Bool = false,
        url: URL
    ) {
        self.id = id
        self.title = title
        self.categoryID = categoryID
        self.isCreated = isCreated
        self.isPlaying = isPlaying
        self.isFavorite = isLiked
        self.url = url
    }
}

// MARK: - Like, Unlike
extension RingtoneAudio {
    public func liked() -> RingtoneAudio {
        RingtoneAudio(
            id: self.id,
            title: self.title,
            categoryID: self.categoryID,
            isCreated: self.isCreated,
            isPlaying: self.isPlaying,
            isLiked: true,
            url: self.url
        )
    }
    
    public func unliked() -> RingtoneAudio {
        RingtoneAudio(
            id: self.id,
            title: self.title,
            categoryID: self.categoryID,
            isCreated: self.isCreated,
            isPlaying: self.isPlaying,
            isLiked: false,
            url: self.url
        )
    }
}

// MARK: - Play, Pause
extension RingtoneAudio {
    public func played() -> RingtoneAudio {
        RingtoneAudio(
            id: self.id,
            title: self.title,
            categoryID: self.categoryID,
            isCreated: self.isCreated,
            isPlaying: true,
            isLiked: self.isFavorite,
            url: self.url
        )
    }
    
    public func paused() -> RingtoneAudio {
        RingtoneAudio(
            id: self.id,
            title: self.title,
            categoryID: self.categoryID,
            isCreated: self.isCreated,
            isPlaying: false,
            isLiked: self.isFavorite,
            url: self.url
        )
    }
}

// MARK: - Empty
extension RingtoneAudio {
    public static var empty: RingtoneAudio {
        .init(
            id: "",
            title: "",
            categoryID: "",
            isCreated: false,
            isPlaying: false,
            isLiked: false,
            url: URL(string: "skh.com")!
        )
    }
}
