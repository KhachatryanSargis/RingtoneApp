//
//  IRingtoneCategoriesStore.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 23.02.25.
//

import Combine

public protocol IRingtoneCategoriesStore {
    func getCategories() -> AnyPublisher<[RingtoneCategory], RingtoneCategoriesStoreError>
}
