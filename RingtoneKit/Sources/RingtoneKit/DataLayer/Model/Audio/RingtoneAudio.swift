//
//  File.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 26.02.25.
//

public struct RingtoneAudio: Equatable, Hashable, Sendable {
    public let title: String
    public let categoryID: String
    public let isCreated: Bool
    
    public init(
        title: String,
        categoryID: String = "Other",
        isCreated: Bool = false
    ) {
        self.title = title
        self.categoryID = categoryID
        self.isCreated = isCreated
    }
}
