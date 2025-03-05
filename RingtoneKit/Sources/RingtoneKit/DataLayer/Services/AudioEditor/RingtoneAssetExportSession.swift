//
//  RingtoneAssetExportSession.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 04.03.25.
//

import Combine
import AVFoundation

final class RingtoneAssetExportSession: AVAssetExportSession, @unchecked Sendable {
    // MARK: - Properties
    private let stateSubject = PassthroughSubject<URL, RingtoneAssetExportSessionError>()
    
    override init?(asset: AVAsset, presetName: String) {
        super.init(asset: asset, presetName: presetName)
    }
    
    func start() -> AnyPublisher<URL, RingtoneAssetExportSessionError> {
        self.exportAsynchronously { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch self.status {
                case .completed:
                    if let url = self.outputURL {
                        self.stateSubject.send(url)
                    } else if let error = self.error {
                        self.stateSubject.send(completion: .failure(.exportFailed(error)))
                    } else {
                        self.stateSubject.send(completion: .failure(.unknown))
                    }
                default:
                    if let error = self.error {
                        self.stateSubject.send(completion: .failure(.exportFailed(error)))
                    } else {
                        self.stateSubject.send(completion: .failure(.unknown))
                    }
                }
                self.stateSubject.send(completion: .finished)
            }
        }
        return self.stateSubject.eraseToAnyPublisher()
    }
}
