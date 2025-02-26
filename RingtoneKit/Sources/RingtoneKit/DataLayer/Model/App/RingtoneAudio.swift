//
//  File.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 26.02.25.
//

public struct RingtoneAudio: Equatable, Hashable, Sendable {
    public let title: String
    
    public init(title: String) {
        self.title = title
    }
}
