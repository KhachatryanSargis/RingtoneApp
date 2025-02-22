//
//  SpotifySeachField.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 21.02.25.
//

import Combine

public protocol ISpotifySearchRepository {
    func search(with fields: [SpotifySearchField]) -> AnyPublisher<SpotifySearchResult, SpotifySearchError>
}
