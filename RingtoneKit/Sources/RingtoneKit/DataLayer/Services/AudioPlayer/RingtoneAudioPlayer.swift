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
    
    public var statusPublisher: AnyPublisher<RingtoneAudioPlayerStatus, Never> {
        return statusSubject.eraseToAnyPublisher()
    }
    private let statusSubject = PassthroughSubject<RingtoneAudioPlayerStatus, Never>()
    
    private var player: AVAudioPlayer?
    
    // MARK: - Methods
    public override init() {
        super.init()
    }
    
    public func play(_ audio: RingtoneAudio) {
        if audio.id == currentAudioID {
            if player?.play() == true {
                currentAudioID = audio.id
                statusSubject.send(.startedPlaying(audioID: audio.id))
            } else {
                currentAudioID = nil
                statusSubject.send(.failedToPlay(audioID: audio.id))
            }
            return
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: audio.url)
            player?.delegate = self
            
            if player?.play() == true {
                currentAudioID = audio.id
                statusSubject.send(.startedPlaying(audioID: audio.id))
            } else {
                currentAudioID = nil
                statusSubject.send(.failedToPlay(audioID: audio.id))
            }
        } catch {
            currentAudioID = nil
            statusSubject.send(.failedToInitialize(error))
        }
    }
    
    public func pause() {
        guard let currentAudioID = self.currentAudioID
        else { return }
        
        player?.pause()
        
        statusSubject.send(.pausedPlaying(audioID: currentAudioID))
    }
}

// MARK: - AVAudioPlayerDelegate
extension RingtoneAudioPlayer: AVAudioPlayerDelegate {
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard let currentAudioID = self.currentAudioID
        else { return }
        
        self.currentAudioID = nil
        
        statusSubject.send(.finishedPlaying(audioID: currentAudioID))
    }
}
