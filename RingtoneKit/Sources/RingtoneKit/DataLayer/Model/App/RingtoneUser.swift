//
//  File.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 22.02.25.
//

import Foundation

public struct RingtoneUser {
    public let id: UUID
    public let isPremiumUser: Bool
    
    public init(id: UUID, isPremiumUser: Bool) {
        self.id = id
        self.isPremiumUser = isPremiumUser
    }
}
