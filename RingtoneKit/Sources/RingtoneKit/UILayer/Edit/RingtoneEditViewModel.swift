//
//  RingtoneEditViewModel.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 15.04.25.
//

import Foundation
import Combine

final public class RingtoneEditViewModel {
    // MARK: - Properties
    @Published private(set) public var update: (
        waveform: RingtoneAudioWaveform,
        startPosition: Double,
        endPosition: Double
    )
    private var waveform: RingtoneAudioWaveform
    
    @Published private(set) public var state: RingtoneEditViewModelState = .isEditing
    @Published private(set) public var startTimeFormatted: String
    @Published private(set) public var endTimeFormatted: String
    @Published private(set) public var durationFormatted: String
    @Published private(set) public var canZoomOut: Bool = false
    @Published private(set) public var canZoomIn: Bool = false
    @Published private(set) public var startPosition: Double = 0.0
    @Published private(set) public var endPosition: Double = 1.0
    @Published private(set) public var progress: Float = 0
    @Published private(set) public var isPlaying: Bool = false
    @Published private(set) public var maximumFadeDuration: TimeInterval
    @Published private(set) public var fadeInDuration: TimeInterval = 0
    @Published private(set) public var fadeOutDuration: TimeInterval = 0
    
    public var title: String
    
    public var hasChanges: Bool {
        shouldUpdateTitle || shouldUpdateAudioData
    }
    
    private var shouldUpdateTitle: Bool {
        audio.title != title
    }
    
    private var shouldUpdateAudioData: Bool {
        zoomRanges.isEmpty == false ||
        startPosition != 0 ||
        endPosition != 1
    }
    
    private var start: TimeInterval
    private var end: TimeInterval
    private var zoomRanges: [(start: TimeInterval, end: TimeInterval)] = []
    private var cancellables: Set<AnyCancellable> = []
    
    private var audio: RingtoneAudio
    private let audioPlayer: IRingtoneAudioPlayer
    private let dataEditor: IRingtoneDataEditor
    private let audioDataChangeResponder: RingtoneAudioDataChangeResponder
    
    // MARK: - Methods
    public init(
        audio: RingtoneAudio,
        audioPlayer: IRingtoneAudioPlayer,
        dataEditor: IRingtoneDataEditor,
        audioDataChangeResponder: RingtoneAudioDataChangeResponder
    ) {
        self.audio = audio
        self.audioPlayer = audioPlayer
        self.dataEditor = dataEditor
        self.audioDataChangeResponder = audioDataChangeResponder
        
        title = audio.title
        
        let waveform = audio.decodeWaveform()
        self.waveform = waveform
        
        start = 0
        end = waveform.duration
        
        startTimeFormatted = TimeInterval(0).formatted()
        endTimeFormatted = waveform.duration.formatted()
        
        durationFormatted = waveform.duration.shortFormatted()
        
        update = (waveform, 0, 1)
        
        maximumFadeDuration = min(3, Double(end - start) / 2)
        
        observeAudioPlayerStatus()
        observeAudioPlayerProgress()
    }
}

// MARK: - Save
extension RingtoneEditViewModel {
    public func save(mode: RingtoneDataEditorMode) {
        audioPlayer.stop()
        
        guard hasChanges else {
            state = .finished
            return
        }
        
        guard shouldUpdateAudioData else {
            audio = audio.changeTitle(title)
            audioDataChangeResponder.saveRingtoneAudio(audio)
            state = .finished
            return
        }
        
        state = .isLoading
        
        dataEditor.trimAudio(audio, start: start, end: end, mode: mode)
            .sink { [weak self] completion in
                guard let self = self else { return }
                
                guard case .failure(let error) = completion else { return }
                
                self.state = .failed(.dataEditor(error))
            } receiveValue: { [weak self] audio in
                guard let self = self else { return }
                
                self.audio = audio.changeTitle(title)
                
                self.audioDataChangeResponder.saveRingtoneAudio(self.audio)
                
                self.state = .finished
            }
            .store(in: &cancellables)
    }
}

// MARK: - Cancel
extension RingtoneEditViewModel {
    public func cancel() {
        audioPlayer.stop()
        
        state = .finished
    }
}

// MARK: - Playback
extension RingtoneEditViewModel {
    public func togglePlayback() {
        if isPlaying {
            audioPlayer.pause()
        } else {
            let range = (start, end)
            audioPlayer.play(audio, range: range)
        }
    }
    
    private func observeAudioPlayerStatus() {
        audioPlayer.statusPublisher
            .sink { [weak self] status in
                guard let self = self else { return }
                
                switch status {
                case .failedToInitialize, .failedToPlay, .pausedPlaying, .finishedPlaying:
                    self.audio = audio.paused()
                    self.isPlaying = false
                case .startedPlaying:
                    self.audio = audio.played()
                    self.isPlaying = true
                }
            }
            .store(in: &cancellables)
    }
    
    private func observeAudioPlayerProgress() {
        audioPlayer.progressPublisher
            .sink(receiveCompletion: { [weak self] _ in
                guard let self = self else { return }
                
                self.progress = 0
            }, receiveValue: { [weak self] progress in
                guard let self = self else { return }
                
                self.progress = progress
            })
            .store(in: &cancellables)
    }
}

// MARK: - Scrabbing
extension RingtoneEditViewModel {
    public func adjustStartTime(by translation: CGFloat) {
        guard waveform.duration > 1 else { return }
        
        let timeDelta = waveform.duration * Double(translation)
        
        let newStart = max(waveform.startTimeInOriginal, start + timeDelta)
        
        guard end - newStart >= 1 else {
            start = end - 1
            startTimeFormatted = start.formatted()
            
            durationFormatted = 1.shortFormatted()
            
            startPosition = (start - waveform.startTimeInOriginal) / waveform.duration
            
            canZoomIn = (start != waveform.startTimeInOriginal || end != waveform.endTimeInOriginal)
            
            maximumFadeDuration = 0.5
            
            return
        }
        
        // Stop playback when selection changes.
        audioPlayer.stop()
        
        resetFade()
        
        start = newStart
        startTimeFormatted = start.formatted()
        
        durationFormatted = (end - start).shortFormatted()
        
        startPosition = (start - waveform.startTimeInOriginal) / waveform.duration
        
        canZoomIn = (start != waveform.startTimeInOriginal || end != waveform.endTimeInOriginal)
        
        maximumFadeDuration = min(3, Double(end - start) / 2)
    }
    
    public func adjustEndTime(by translation: CGFloat) {
        guard waveform.duration > 1 else { return }
        
        let timeDelta = waveform.duration * Double(translation)
        
        let newEnd = min(waveform.endTimeInOriginal, end + timeDelta)
        
        guard newEnd - start >= 1 else {
            end = start + 1
            endTimeFormatted = end.formatted()
            
            durationFormatted = 1.shortFormatted()
            
            endPosition = (end - waveform.startTimeInOriginal) / waveform.duration
            
            canZoomIn = (end != waveform.endTimeInOriginal || start != waveform.startTimeInOriginal)
            
            maximumFadeDuration = 0.5
            
            return
        }
        
        // Stop playback when selection changes.
        audioPlayer.stop()
        
        resetFade()
        
        end = newEnd
        endTimeFormatted = end.formatted()
        
        durationFormatted = (end - start).shortFormatted()
        
        endPosition = (end - waveform.startTimeInOriginal) / waveform.duration
        
        canZoomIn = (end != waveform.endTimeInOriginal || start != waveform.startTimeInOriginal)
        
        maximumFadeDuration = min(3, Double(end - start) / 2)
    }
}

// MARK: - Zoom
extension RingtoneEditViewModel {
    public func zoomIn() {
        guard canZoomIn else { return }
        
        // Stop playback when selection changes.
        audioPlayer.stop()
        
        resetFade(sendUpdate: false)
        
        state = .isLoading
        canZoomIn = false
        canZoomOut = false
        
        dataEditor.zoomWaveform(audio, start: start, end: end)
            .sink { [weak self] completion in
                guard let self = self else { return }
                
                guard case .failure(let error) = completion
                else {
                    self.state = .isEditing
                    return
                }
                
                self.state = .failed(.dataEditor(error))
            } receiveValue: { [weak self] waveform in
                guard let self = self else { return }
                
                self.zoomRanges.append((start, end))
                
                self.canZoomIn = false
                self.canZoomOut = true
                
                let startPosition: Double = 0
                let endPosition: Double = 1
                
                self.update = (waveform, startPosition, endPosition)
                self.waveform = waveform
                
                self.startPosition = startPosition
                self.endPosition = endPosition
            }
            .store(in: &cancellables)
    }
    
    public func zoomOut() {
        guard canZoomOut else { return }
        
        // Stop playback when selection changes.
        audioPlayer.stop()
        
        canZoomIn = false
        canZoomOut = false
        
        if zoomRanges.count == 1 {
            resetZoom()
        } else {
            resetFade(sendUpdate: false)
            
            state = .isLoading
            
            let zoom = zoomRanges[zoomRanges.count - 2]
            
            dataEditor.zoomWaveform(audio, start: zoom.start, end: zoom.end)
                .sink { [weak self] completion in
                    guard let self = self else { return }
                    
                    guard case .failure(let error) = completion
                    else {
                        self.state = .isEditing
                        return
                    }
                    
                    self.state = .failed(.dataEditor(error))
                } receiveValue: { [weak self] waveform in
                    guard let self = self else { return }
                    
                    let zoom = self.zoomRanges.remove(at: zoomRanges.count - 1)
                    
                    self.canZoomOut = !self.zoomRanges.isEmpty
                    self.canZoomIn = true
                    
                    self.start = zoom.start
                    self.end = zoom.end
                    
                    self.startTimeFormatted = zoom.start.formatted()
                    self.endTimeFormatted = zoom.end.formatted()
                    
                    self.durationFormatted = (end - start).shortFormatted()
                    
                    let startPosition = (zoom.start - waveform.startTimeInOriginal) / waveform.duration
                    let endPosition = (zoom.end - waveform.startTimeInOriginal) / waveform.duration
                    
                    self.update = (waveform, startPosition, endPosition)
                    self.waveform = waveform
                    
                    self.startPosition = startPosition
                    self.endPosition = endPosition
                }
                .store(in: &cancellables)
        }
    }
    
    public func resetZoom() {
        guard let zoom = zoomRanges.first else { return }
        
        zoomRanges.removeAll()
        
        // Stop playback when selection changes.
        audioPlayer.stop()
        
        resetFade(sendUpdate: false)
        
        canZoomOut = false
        canZoomIn = true
        
        start = zoom.start
        end = zoom.end
        
        startTimeFormatted = zoom.start.formatted()
        endTimeFormatted = zoom.end.formatted()
        
        durationFormatted = (end - start).shortFormatted()
        
        let waveform = audio.decodeWaveform()
        
        let startPosition = (zoom.start - waveform.startTimeInOriginal) / waveform.duration
        let endPosition = (zoom.end - waveform.startTimeInOriginal) / waveform.duration
        
        self.update = (waveform, startPosition, endPosition)
        self.waveform = waveform
        
        self.startPosition = startPosition
        self.endPosition = endPosition
    }
}

// MARK: - Fade
extension RingtoneEditViewModel {
    public func fadeIn(duration: TimeInterval) {
        fadeInDuration = duration
        
        let fadeInPosition = fadeInDuration / (end - start)
        let fadeOutPosition = fadeOutDuration / (end - start)
        
        let waveform = waveform
            .fadeIn(range: (startPosition, endPosition), position: fadeInPosition)
            .fadeOut(range: (startPosition, endPosition), position: fadeOutPosition)
        
        update = (waveform, startPosition, endPosition)
    }
    
    public func fadeOut(duration: TimeInterval) {
        fadeOutDuration = duration
        
        let fadeOutPosition = fadeOutDuration / (end - start)
        let fadeInPosition = fadeInDuration / (end - start)
        
        let waveform = waveform
            .fadeOut(range: (startPosition, endPosition), position: fadeOutPosition)
            .fadeIn(range: (startPosition, endPosition), position: fadeInPosition)
        
        update = (waveform, startPosition, endPosition)
    }
    
    private func resetFade(sendUpdate: Bool = true) {
        guard fadeInDuration != 0 || fadeOutDuration != 0
        else { return }
        
        fadeInDuration = 0
        fadeOutDuration = 0
        
        guard sendUpdate else { return }
        
        update = (waveform, startPosition, endPosition)
    }
}
