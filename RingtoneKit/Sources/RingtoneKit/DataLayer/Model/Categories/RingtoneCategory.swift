//
//  RingtoneCategory.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 22.02.25.
//

import Foundation

public struct RingtoneCategory: Sendable, Equatable, Hashable {
    public struct Color: Sendable, Equatable, Hashable {
        public let lightHex: String
        public let darkHex: String
    }
    
    public let displayName: String
    public let folderName: String
    public let color: Color
}
