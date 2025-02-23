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
        fatalError()
    }
}
