//
//  File.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 22.02.25.
//

import Combine

public protocol IRingtoneCategoriesRepository {
    func getCategories() -> AnyPublisher<[RingtoneCategory], RingtoneCategoriesRepositoryError>
}
