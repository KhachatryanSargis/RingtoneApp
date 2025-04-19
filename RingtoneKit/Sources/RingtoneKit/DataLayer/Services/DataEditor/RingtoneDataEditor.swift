//
//  RingtoneDataEditor.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 16.04.25.
//

import Foundation
import Combine

public final class RingtoneDataEditor: IRingtoneDataEditor, @unchecked Sendable {
    // MARK: - Properties
    private let queue = OperationQueue()
    
    // MARK: - Methods
    public init() {
        queue.underlyingQueue = .global(qos: .utility)
        queue.maxConcurrentOperationCount = 10
    }
}

// MARK: - Audio
extension RingtoneDataEditor {
    public func trimAudio(_ audio: RingtoneAudio, start: TimeInterval, end: TimeInterval) -> AnyPublisher<RingtoneAudio, RingtoneDataTrimmerError> {
        Future { [weak self] promise in
            guard let self = self else { return }
            
            let trimAudioOperation = TrimAudioOperation(
                audio: audio,
                start: start,
                end: end) { result in
                    switch result {
                    case .success(let audio):
                        promise(.success(audio))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
            
            self.queue.addOperation(trimAudioOperation)
        }
        .subscribe(on: queue)
        .eraseToAnyPublisher()
    }
}

// MARK: - Waveform
extension RingtoneDataEditor {
    public func zoomWaveform(_ audio: RingtoneAudio, start: TimeInterval, end: TimeInterval) -> AnyPublisher<RingtoneAudioWaveform, RingtoneDataTrimmerError> {
        Future { [weak self] promise in
            guard let self = self else { return }
            
            let zoomWaveformOperation = ZoomWaveformOperation(
                audio: audio,
                start: start,
                end: end) { result in
                    switch result {
                    case .success(let waveform):
                        promise(.success(waveform))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
            
            self.queue.addOperation(zoomWaveformOperation)
        }
        .subscribe(on: queue)
        .eraseToAnyPublisher()
    }
}
