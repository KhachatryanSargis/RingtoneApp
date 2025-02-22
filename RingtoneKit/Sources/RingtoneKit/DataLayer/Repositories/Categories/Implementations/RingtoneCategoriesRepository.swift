//
//  RingtoneCategoriesRepository.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 22.02.25.
//

import Combine

public final class RingtoneCategoriesRepository: IRingtoneCategoriesRepository {
    private let api: IRingtoneCategoriesAPI
    
    // MARK: - Methods
    public init(api: IRingtoneCategoriesAPI) {
        self.api = api
    }
    
    public func getCategories() -> AnyPublisher<[RingtoneCategory], RingtoneCategoriesRepositoryError> {
        api.getCategories()
            .mapError { .api($0) }
            .eraseToAnyPublisher()
    }
}
