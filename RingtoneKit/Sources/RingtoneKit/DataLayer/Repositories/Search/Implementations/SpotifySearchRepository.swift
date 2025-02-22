//
//  File.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 21.02.25.
//

import Combine
import Alamofire

public final class SpotifySearchRepository: ISpotifySearchRepository {
    // MARK: - Methods
    public func search(with fields: [SpotifySearchField]) -> AnyPublisher<SpotifySearchResult, SpotifySearchError> {
        fatalError("not implemented")
    }
}
