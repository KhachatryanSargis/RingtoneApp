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
    
    // MARK: - Methods
    public override init() {
        super.init()
    }
}

// MARK: - Play, Pause
extension RingtoneAudioPlayer {
    public func play(_ audio: RingtoneAudio) {
        if audio.id == currentAudioID {
            if player?.play() == true {
                currentAudioID = audio.id
                statusSubject.send(.startedPlaying(audioID: audio.id))
                
                startDisplayLink()
            } else {
                currentAudioID = nil
                statusSubject.send(.failedToPlay(audioID: audio.id))
                
                stopDisplayLink()
            }
            return
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: audio.url)
            player?.delegate = self
            
            if player?.play() == true {
                currentAudioID = audio.id
                statusSubject.send(.startedPlaying(audioID: audio.id))
                
                startDisplayLink()
            } else {
                currentAudioID = nil
                statusSubject.send(.failedToPlay(audioID: audio.id))
                
                stopDisplayLink()
            }
        } catch {
            currentAudioID = nil
            statusSubject.send(.failedToInitialize(error))
            
            stopDisplayLink()
        }
    }
    
    public func pause() {
        guard let currentAudioID = self.currentAudioID
        else { return }
        
        player?.pause()
        
        statusSubject.send(.pausedPlaying(audioID: currentAudioID))
        
        pauseDisplayLink()
    }
}

// MARK: - AVAudioPlayerDelegate
extension RingtoneAudioPlayer: AVAudioPlayerDelegate {
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard let currentAudioID = self.currentAudioID
        else { return }
        
        self.currentAudioID = nil
        
        statusSubject.send(.finishedPlaying(audioID: currentAudioID))
        
        stopDisplayLink()
    }
}

// MARK: - Progress
extension RingtoneAudioPlayer {
    private func startDisplayLink() {
        // Create the display link to update the progress bar every frame
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
        
        let currentTime = player.currentTime
        let duration = player.duration
        
        let progress = Float(currentTime / duration)
        
        // If the audio is finished, stop the timer
        if currentTime >= duration {
            stopDisplayLink()
        }
        
        progressSubject.send(progress)
    }
}
