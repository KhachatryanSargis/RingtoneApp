//
//  ViewController.swift
//  RingtoneApp
//
//  Created by Sargis Khachatryan on 21.02.25.
//

import UIKit

fileprivate let baseURL = "https://api.spotify.com/v1"

fileprivate struct AccessToken: Codable {
    static let storageKey = "access_token"
    
    let token: String
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case token = "access_token"
        case type = "token_type"
    }
}

fileprivate var accessToken: AccessToken? {
    get {
        guard let encodedAccessToken = UserDefaults.standard.data(forKey: AccessToken.storageKey),
              let accessToken = try? JSONDecoder().decode(AccessToken.self, from: encodedAccessToken)
        else { return nil }
        return accessToken
    }
    set {
        guard let accessToken = newValue,
              let encodedAccessToken = try? JSONEncoder().encode(accessToken)
        else {
            UserDefaults.standard.setValue(nil, forKey: AccessToken.storageKey)
            return
        }
        UserDefaults.standard.setValue(
            encodedAccessToken,
            forKey: AccessToken.storageKey
        )
    }
}

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCategories()
    }
}

// MARK: - Regenerate Access Token
extension ViewController {
    private func regenerateAccessToken(completion: @escaping () -> Void) {
        let url = URL(string: "https://accounts.spotify.com/api/token")!
        
        let parameters = [
            "grant_type": "client_credentials",
            "client_id": "d703421df30349d189091bc8de7dae4d",
            "client_secret": "87d62a68018b4e36ad779317fd9394f4"
        ]
        
        let bodyString = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue(
            "application/x-www-form-urlencoded",
            forHTTPHeaderField: "Content-Type"
        )
        urlRequest.httpBody = bodyString.data(using: .utf8)
        
        URLSession.shared.dataTask(with: urlRequest) { data, _, _ in
            guard let data = data,
                  let newToken = try? JSONDecoder().decode(AccessToken.self, from: data)
            else {
                accessToken = nil
                print("Failed to regenerate access token!")
                return
            }
            accessToken = newToken
            completion()
        }.resume()
    }
}

// MARK: - Artist Request
extension ViewController {
    private func fetchArtist() {
        guard let currentToken = accessToken else {
            regenerateAccessToken { [weak self] in
                guard let self = self else { return }
                self.fetchArtist()
            }
            return
        }
        
        let url = URL(string: "\(baseURL)/artists/2YZyLoL8N0Wb9xBt1NhZWg?si=e8vOyT_CTMa537Bs3JGIRw")!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue(
            "\(currentToken.type) \(currentToken.token)",
            forHTTPHeaderField: "Authorization"
        )
        
        URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
            guard let self = self else { return }
            guard let httpResponse = response as? HTTPURLResponse else {
                print("!!! fetchArtist failed !!! no HTTP response")
                return
            }
            
            guard httpResponse.statusCode != 401 else {
                print("Regenerating access token ...")
                self.regenerateAccessToken { [weak self] in
                    guard let self = self else { return }
                    self.fetchArtist()
                }
                return
            }
            
            guard let data = data
            else {
                print("!!! fetchArtist failed !!! no data")
                return
            }
            
            guard let dataString = String(data: data, encoding: .utf8)
            else {
                print("!!! fetchArtist failed !!! no data string")
                return
            }
            
            print("=== Spotify Data ===")
            print(dataString)
            print("=== Spotify Data ===")
        }
        .resume()
    }
}

// MARK: - Categories
extension ViewController {
    private func fetchCategories() {
        guard let currentToken = accessToken else {
            regenerateAccessToken { [weak self] in
                guard let self = self else { return }
                self.fetchArtist()
            }
            return
        }
        
        let url = URL(string: "\(baseURL)/browse/categories")!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue(
            "\(currentToken.type) \(currentToken.token)",
            forHTTPHeaderField: "Authorization"
        )
        
        URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
            guard let self = self else { return }
            guard let httpResponse = response as? HTTPURLResponse else {
                print("!!! fetchCategories failed !!! no HTTP response")
                return
            }
            
            guard httpResponse.statusCode != 401 else {
                print("Regenerating access token ...")
                self.regenerateAccessToken { [weak self] in
                    guard let self = self else { return }
                    self.fetchCategories()
                }
                return
            }
            
            guard let data = data
            else {
                print("!!! fetchCategories failed !!! no data")
                return
            }
            
            guard let dataString = String(data: data, encoding: .utf8)
            else {
                print("!!! fetchCategories failed !!! no data string")
                return
            }
            
            print("=== Spotify Data ===")
            print(dataString)
            print("=== Spotify Data ===")
        }
        .resume()
    }
}
