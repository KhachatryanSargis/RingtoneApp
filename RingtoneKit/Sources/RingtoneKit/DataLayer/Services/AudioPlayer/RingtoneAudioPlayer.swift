//
//  RingtoneAudioPlayer.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 02.03.25.
//

import Combine
import AVFoundation

public final class RingtoneAudioPlayer: NSObject, IRingtoneAudioPlayer {
    // MARK: - Properties
    public var currentAudioID: String?
    public var isPlaying: Bool {
        return player?.isPlaying ?? false
    }
    
    public var statusPublisher: AnyPublisher<RingtoneAudioPlayerStatus, Never> {
        return statusSubject.eraseToAnyPublisher()
    }
    private let statusSubject = PassthroughSubject<RingtoneAudioPlayerStatus, Never>()
    
    public var progressPublisher: AnyPublisher<Float, Never> {
        return progressSubject.eraseToAnyPublisher()
    }
    private let progressSubject = PassthroughSubject<Float, Never>()
    
    private var player: AVAudioPlayer?
    private var displayLink: CADisplayLink?
    
    private var timeRange: (start: TimeInterval, end: TimeInterval)?
}

// MARK: - Play
extension RingtoneAudioPlayer {
    public func play(_ audio: RingtoneAudio) {
        timeRange = nil
        
        if audio.id == currentAudioID {
            play(with: audio.id)
        } else {
            do {
                player = try AVAudioPlayer(contentsOf: audio.url)
                player?.delegate = self
                
                play(with: audio.id)
            } catch {
                fail(with: error)
            }
        }
    }
    
    private func play(with audioID: String) {
        if player?.play() == true {
            currentAudioID = audioID
            statusSubject.send(.startedPlaying(audioID: audioID))
            
            startDisplayLink()
        } else {
            currentAudioID = nil
            statusSubject.send(.failedToPlay(audioID: audioID))
            
            stopDisplayLink()
        }
    }
    
    private func fail(with error: Error) {
        currentAudioID = nil
        statusSubject.send(.failedToInitialize(error))
        
        stopDisplayLink()
    }
}

// MARK: - Play Time Range
extension RingtoneAudioPlayer {
    public func play(_ audio: RingtoneAudio, range: (start: TimeInterval, end: TimeInterval)) {
        if audio.id == currentAudioID {
            if let timeRange = timeRange, timeRange == range {
                play(with: audio.id)
            } else {
                self.timeRange = range
                player?.currentTime = range.start
                
                play(with: audio.id)
            }
        } else {
            do {
                self.timeRange = range
                
                player = try AVAudioPlayer(contentsOf: audio.url)
                player?.delegate = self
                player?.currentTime = range.start
                
                play(with: audio.id)
            } catch {
                fail(with: error)
            }
        }
    }
}

// MARK: - Pause, Stop, Reset
extension RingtoneAudioPlayer {
    public func pause() {
        guard let currentAudioID = self.currentAudioID
        else { return }
        
        player?.pause()
        
        statusSubject.send(.pausedPlaying(audioID: currentAudioID))
        
        pauseDisplayLink()
    }
    
    public func stop() {
        guard let currentAudioID = self.currentAudioID
        else { return }
        
        self.currentAudioID = nil
        
        player?.stop()
        
        statusSubject.send(.finishedPlaying(audioID: currentAudioID))
        
        stopDisplayLink()
    }
    
    public func reset() {
        self.timeRange = nil
        
        guard let currentAudioID = self.currentAudioID
        else { return }
        
        player?.pause()
        
        statusSubject.send(.pausedPlaying(audioID: currentAudioID))
        
        stopDisplayLink()
    }
}

// MARK: - AVAudioPlayerDelegate
extension RingtoneAudioPlayer: AVAudioPlayerDelegate {
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stop()
    }
}

// MARK: - Progress
extension RingtoneAudioPlayer {
    private func startDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateProgress))
        displayLink?.add(to: .current, forMode: .common)
    }
    
    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
        progressSubject.send(0.0)
    }
    
    private func pauseDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc func updateProgress() {
        guard let player = player else { return }
        
        if let range = timeRange {
            let currentTime = player.currentTime - range.start
            let duration = range.end - range.start
            
            if currentTime >= duration {
                stop()
            } else {
                let progress = Float(currentTime / duration)
                
                progressSubject.send(progress)
            }
        } else {
            let currentTime = player.currentTime
            let duration = player.duration
            
            if currentTime >= duration {
                stopDisplayLink()
            } else {
                let progress = Float(currentTime / duration)
                
                progressSubject.send(progress)
            }
        }
    }
}
