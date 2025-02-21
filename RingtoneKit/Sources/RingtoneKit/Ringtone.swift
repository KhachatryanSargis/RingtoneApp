//
//  Ringtone.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 21.02.25.
//

import Foundation

public struct Ringtone: Identifiable {
    public let id: UUID
    public let name: String
    public let thumbnailUrl: URL
    public let audioUrl: URL
    
    public init(
        id: UUID,
        name: String,
        thumbnailUrl: URL,
        audioUrl: URL
    ) {
        self.id = id
        self.name = name
        self.thumbnailUrl = thumbnailUrl
        self.audioUrl = audioUrl
    }
}
