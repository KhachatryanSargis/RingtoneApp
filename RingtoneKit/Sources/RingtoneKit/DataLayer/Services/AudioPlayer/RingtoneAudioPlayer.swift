//
//  RingtoneAudioPlayer.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 02.03.25.
//

import Combine
import AVFoundation

public final class RingtoneAudioPlayer: NSObject, IRingtoneAudioPlayer, @unchecked Sendable {
    // MARK: - Properties
    public var currentAudioID: String?
    
    public var progressPublisher: AnyPublisher<Float, Never> {
        progressSubject.eraseToAnyPublisher()
    }
    private let progressSubject = PassthroughSubject<Float, Never>()
    
    public var statusPublisher: AnyPublisher<RingtoneAudioPlayerStatus, Never> {
        statusSubject.eraseToAnyPublisher()
    }
    private let statusSubject = PassthroughSubject<RingtoneAudioPlayerStatus, Never>()
    
    private let player = AVPlayer()
    private var boundaryObserver: Any?
    private var timeObserverToken: Any?
    
    // MARK: - Methods
    public override init() {
        super.init()
    }
    
    public func play(_ audio: RingtoneAudio) {
        if currentAudioID == audio.id {
            play(audioID: audio.id)
            return
        }
        
        let asset = AVURLAsset(url: audio.url)
        let item = AVPlayerItem(asset: asset)
        
        player.replaceCurrentItem(with: item)
        
        let duration = CMTimeGetSeconds(asset.duration)
        let timescale = asset.duration.timescale
        
        startProgressTracking(duration: duration, timescale: timescale, range: nil)
        
        let endTime = asset.duration
        
        startEndTracking(endTime)
        
        play(audioID: audio.id)
    }
    
    public func play(_ audio: RingtoneAudio, range: (start: TimeInterval, end: TimeInterval)) {
        if currentAudioID == audio.id {
            play(audioID: audio.id)
            return
        }
        
        let asset = AVURLAsset(url: audio.url)
        let item = AVPlayerItem(asset: asset)
        
        player.replaceCurrentItem(with: item)
        
        let timescale = asset.duration.timescale
        let startTime = CMTime(seconds: range.start, preferredTimescale: timescale)
        
        player.seek(to: startTime, toleranceBefore: .zero, toleranceAfter: .zero)
        
        let duration = range.end - range.start
        
        startProgressTracking(duration: duration, timescale: timescale, range: range)
        
        let endTime = CMTime(seconds: range.end, preferredTimescale: timescale)
        
        startEndTracking(endTime)
        
        play(audioID: audio.id)
    }
    
    public func pause() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            guard let currentAudioID = self.currentAudioID
            else { return }
            
            self.player.pause()
            
            self.statusSubject.send(.pausedPlaying(audioID: currentAudioID))
        }
    }
    
    public func stop() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            guard let currentAudioID = self.currentAudioID
            else { return }
            
            self.stopEndTracking()
            
            self.stopProgressTracking()
            
            self.currentAudioID = nil
            
            self.player.replaceCurrentItem(with: nil)
            
            self.statusSubject.send(.finishedPlaying(audioID: currentAudioID))
        }
    }
}

// MARK: - Play
extension RingtoneAudioPlayer {
    private func play(audioID: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.currentAudioID = audioID
            
            self.player.play()
            
            self.statusSubject.send(.startedPlaying(audioID: audioID))
        }
    }
}

// MARK: - End
extension RingtoneAudioPlayer {
    private func startEndTracking(_ endTime: CMTime) {
        stopEndTracking()
        
        boundaryObserver = player.addBoundaryTimeObserver(
            forTimes: [NSValue(time: endTime)],
            queue: .main
        ) {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.stop()
            }
        }
    }
    
    private func stopEndTracking() {
        guard let boundaryObserver = boundaryObserver else { return }
        
        self.boundaryObserver = nil
        
        player.removeTimeObserver(boundaryObserver)
    }
}

// MARK: - Progress
extension RingtoneAudioPlayer {
    private func startProgressTracking(
        duration: TimeInterval,
        timescale: CMTimeScale,
        range: (start: TimeInterval, end: TimeInterval)?
    ) {
        stopProgressTracking()
        
        timeObserverToken = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.1, preferredTimescale: timescale),
            queue: .main
        ) { time in
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                if let range = range {
                    let currentTime = CMTimeGetSeconds(time) - range.start
                    
                    let progress = Float(currentTime / duration)
                    
                    self.progressSubject.send(progress)
                } else {
                    let currentTime = CMTimeGetSeconds(time)
                    
                    let progress = Float(currentTime / duration)
                    
                    print(progress)
                    
                    self.progressSubject.send(progress)
                }
            }
        }
    }
    
    private func stopProgressTracking() {
        guard let timeObserverToken = timeObserverToken else { return }
        
        self.timeObserverToken = nil
        
        player.removeTimeObserver(timeObserverToken)
        
        progressSubject.send(0)
    }
}
