//
//  RingtoneEditViewModel.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 15.04.25.
//

import Foundation

final public class RingtoneEditViewModel {
    // MARK: - Properties
    @Published private(set) public var waveform: RingtoneAudioWaveform
    @Published private(set) public var startTime: String
    @Published private(set) public var endTime: String
    
    public var title: String
    
    private var start: TimeInterval
    private var end: TimeInterval
    
    private let audio: RingtoneAudio
    private let audioPlayer: RingtoneAudioPlayer
    
    // MARK: - Methods
    public init(audio: RingtoneAudio, audioPlayer: RingtoneAudioPlayer) {
        self.audio = audio
        self.title = audio.title
        
        let waveform = audio.decodeWaveform()
        self.waveform = waveform
        
        self.start = 0
        self.end = waveform.duration
        
        self.startTime = TimeInterval(0).formatted()
        self.endTime = waveform.duration.formatted()
        
        self.audioPlayer = audioPlayer
    }
    
    public func selectTrimmingPositions(startPosition: Double, endPosition: Double) -> Bool {
        guard startPosition >= 0 && endPosition <= 1 else { return false }
        
        let startIndex = Int(startPosition * CGFloat(waveform.count))
        let endIndex = Int(endPosition * CGFloat(waveform.count))
        
        let validStartIndex = max(0, startIndex)
        let validEndIndex = min(waveform.count, endIndex)
        
        let start = waveform.time(at: validStartIndex)
        self.start = start
        startTime = start.formatted()
        
        let end = waveform.time(at: validEndIndex)
        self.end = end
        endTime = end.formatted()
        
        return waveform.duration(from: validStartIndex, to: validEndIndex) >= 1
    }
    
    public func resetStartTrimmingPosition() {
        let start: TimeInterval = 0
        self.start = start
        startTime = start.formatted()
    }
    
    public func resetEndTrimmingPosition() {
        let end = waveform.duration
        self.end = end
        endTime = end.formatted()
    }
    
    public func resetTrimmingPositions() {
        resetStartTrimmingPosition()
        resetEndTrimmingPosition()
    }
}

// MARK: - Format Time Interval
extension TimeInterval {
    func formatted() -> String {
        let totalSeconds = Int(self)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        let milliseconds = Int((self - floor(self)) * 1000)
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d.%03d", hours, minutes, seconds, milliseconds)
        } else {
            return String(format: "%02d:%02d.%03d", minutes, seconds, milliseconds)
        }
    }
}
