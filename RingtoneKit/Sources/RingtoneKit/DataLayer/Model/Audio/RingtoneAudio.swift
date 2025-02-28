//
//  File.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 26.02.25.
//

import Foundation

public struct RingtoneAudio: Identifiable, Equatable, Hashable, Sendable {
    public var id: String {
        return title
    }
    public let title: String
    public let categoryID: String
    public let isCreated: Bool
    public let isPlaying: Bool
    public let isLiked: Bool
    
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
        self.isLiked = isLiked
    }
}

// MARK: - Like, Unlike
extension RingtoneAudio {
    public func likeToggled() -> RingtoneAudio {
        RingtoneAudio(
            title: self.title,
            categoryID: self.categoryID,
            isCreated: self.isCreated,
            isPlaying: self.isPlaying,
            isLiked: self.isLiked ? false : true
        )
    }
}
