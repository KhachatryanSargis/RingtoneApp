//
//  IRingtoneCategoriesAPI.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 22.02.25.
//

import Combine

public protocol IRingtoneCategoriesAPI {
    func getCategories() -> AnyPublisher<[RingtoneCategory], RingtoneCategoriesAPIError>
}
