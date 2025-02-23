//
//  RingtoneCategoriesRepository.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 22.02.25.
//

import Combine

public final class RingtoneCategoriesRepository: IRingtoneCategoriesRepository {
    private let store: IRingtoneCategoriesStore
    
    // MARK: - Methods
    public init(store: IRingtoneCategoriesStore) {
        self.store = store
    }
    
    public func getCategories() -> AnyPublisher<[RingtoneCategory], RingtoneCategoriesRepositoryError> {
        store.getCategories()
            .mapError { .store($0) }
            .eraseToAnyPublisher()
    }
}
