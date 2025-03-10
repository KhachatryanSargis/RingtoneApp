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
    public let isLoading: Bool
    public let url: URL
    
    public init(
        id: String,
        title: String,
        categoryID: String = "Other",
        isCreated: Bool = false,
        isPlaying: Bool = false,
        isLiked: Bool = false,
        isLoading: Bool = false,
        url: URL
    ) {
        self.id = id
        self.title = title
        self.categoryID = categoryID
        self.isCreated = isCreated
        self.isPlaying = isPlaying
        self.isFavorite = isLiked
        self.isLoading = isLoading
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
            isLoading: self.isLoading,
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
            isLoading: self.isLoading,
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
            isLoading: self.isLoading,
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
            isLoading: self.isLoading,
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
            isLoading: false,
            url: URL(string: "skh.com")!
        )
    }
}

// MARK: - Loading
extension RingtoneAudio {
    public static func loading(item: RingtoneDataImporterRemoteItem) -> RingtoneAudio {
        .init(
            id: item.id.uuidString,
            title: item.name,
            categoryID: "",
            isCreated: false,
            isPlaying: false,
            isLiked: false,
            isLoading: true,
            url: item.url
        )
    }
}
