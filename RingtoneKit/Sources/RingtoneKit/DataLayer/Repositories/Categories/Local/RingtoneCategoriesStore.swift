//
//  RingtoneCategoriesStore.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 23.02.25.
//

import Combine

public final class RingtoneCategoriesStore: IRingtoneCategoriesStore {
    public init() {}
    
    public func getCategories() -> AnyPublisher<[RingtoneCategory], RingtoneCategoriesStoreError> {
        Just(categories)
            .setFailureType(to: RingtoneCategoriesStoreError.self)
            .eraseToAnyPublisher()
    }
}

fileprivate let categories: [RingtoneCategory] = [
    .init(displayName: "Trending", folderName: "", color: .init(lightHex: "bde0fe", darkHex: "023e8a")),
    .init(displayName: "Hip Hop", folderName: "", color: .init(lightHex: "ccd5ae", darkHex: "386641")),
    .init(displayName: "Jazz", folderName: "", color: .init(lightHex: "83c5be", darkHex: "006d77")),
    .init(displayName: "Electro", folderName: "", color: .init(lightHex: "e0aaff", darkHex: "451f55")),
    .init(displayName: "Prank", folderName: "", color: .init(lightHex: "ffa5ab", darkHex: "9e2a2b")),
    .init(displayName: "Meme", folderName: "", color: .init(lightHex: "ffe169", darkHex: "a47e1b")),
]
