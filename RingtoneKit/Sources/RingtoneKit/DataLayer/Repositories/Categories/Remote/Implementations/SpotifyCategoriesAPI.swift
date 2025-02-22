//
//  SpotifyCategoriesAPI.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 22.02.25.
//

import Combine

public final class SpotifyCategoriesAPI: IRingtoneCategoriesAPI {
    public func getCategories() -> AnyPublisher<[RingtoneCategory], RingtoneCategoriesAPIError> {
        fatalError("not implemented")
    }
}

// MARK: - Categories
//extension ViewController {
//    private func fetchCategories() {
//        guard let currentToken = accessToken else {
//            regenerateAccessToken { [weak self] in
//                guard let self = self else { return }
//                self.fetchArtist()
//            }
//            return
//        }
//
//        let url = URL(string: "\(baseURL)/browse/categories")!
//
//        var urlRequest = URLRequest(url: url)
//        urlRequest.setValue(
//            "\(currentToken.type) \(currentToken.token)",
//            forHTTPHeaderField: "Authorization"
//        )
//
//        URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
//            guard let self = self else { return }
//            guard let httpResponse = response as? HTTPURLResponse else {
//                print("!!! fetchCategories failed !!! no HTTP response")
//                return
//            }
//
//            guard httpResponse.statusCode != 401 else {
//                print("Regenerating access token ...")
//                self.regenerateAccessToken { [weak self] in
//                    guard let self = self else { return }
//                    self.fetchCategories()
//                }
//                return
//            }
//
//            guard let data = data
//            else {
//                print("!!! fetchCategories failed !!! no data")
//                return
//            }
//
//            guard let dataString = String(data: data, encoding: .utf8)
//            else {
//                print("!!! fetchCategories failed !!! no data string")
//                return
//            }
//
//            print("=== Spotify Data ===")
//            print(dataString)
//            print("=== Spotify Data ===")
//        }
//        .resume()
//    }
//}
