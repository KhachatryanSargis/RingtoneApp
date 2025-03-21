//
//  RingtoneCreatedViewModel.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 24.02.25.
//

import Foundation
import Combine

public protocol RingtoneCreatedViewModelFactory {
    func makeRingtoneCreatedViewModel() -> RingtoneCreatedViewModel
}

public final class RingtoneCreatedViewModel {
    // MARK: - Properties
    @Published public private(set) var isLoading: Bool = false
    @Published public private(set) var canSelect: Bool = false
    @Published public private(set) var isSelectionEnabled: Bool = false
    @Published public private(set) var hasSelectedAudios: Bool = false
    @Published public private(set) var action: RingtoneCreatedAction?
    @Published public private(set) var audios: [RingtoneAudio] = [] {
        didSet {
            canSelect = audios.contains(where: { $0.isFailed == false })
            hasSelectedAudios = audios.contains(where: { $0.isSelected == true })
            if audios.isEmpty { isSelectionEnabled = false }
        }
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    private let audioRepository: IRingtoneAudioRepository
    public let audioFavoriteStatusChangeResponder: RingtoneAudioFavoriteStatusChangeResponder
    public let audioImportResponder: RingtoneAudioImportResponder
    private let audioPlayer: IRingtoneAudioPlayer
    private let dataExporterFactory: () -> IRingtoneDataExporter
    
    // MARK: - Methods
    public init(
        audioRepository: IRingtoneAudioRepository,
        audiofavoriteStatusChangeResponder: RingtoneAudioFavoriteStatusChangeResponder,
        audioPlayer: IRingtoneAudioPlayer,
        audioImportResponder: RingtoneAudioImportResponder,
        dataExporterFactory: @escaping () -> IRingtoneDataExporter
    ) {
        self.audioRepository = audioRepository
        self.audioFavoriteStatusChangeResponder = audiofavoriteStatusChangeResponder
        self.audioPlayer = audioPlayer
        self.audioImportResponder = audioImportResponder
        self.dataExporterFactory = dataExporterFactory
        
        getCreatedRingtoneAudios()
        observeFavoriteAudios()
        observeAudioPlayerStatus()
        observeImportedAudios()
    }
    
    public func clearFailedRingtoneAudios() {
        audios.removeAll(where: { $0.failedToImport || $0.failedToConvert })
        audioImportResponder.clearAll()
    }
    
    public func retryFailedRingtoneAudio(_ audio: RingtoneAudio) {
        audios.removeAll(where: { $0.id == audio.id })
        audioImportResponder.clearByID(audio.id)
    }
    
    public func retryFailedRingtoneAudios() {
        audios.removeAll(where: { $0.failedToImport || $0.failedToConvert })
        audioImportResponder.retryAll()
    }
    
    public func cleanFailedRingtoneAudio(_ audio: RingtoneAudio) {
        audios.removeAll(where: { $0.id == audio.id })
        audioImportResponder.retryByID(audio.id)
    }
}

// MARK: - Selection
extension RingtoneCreatedViewModel {
    @discardableResult
    public func enableSelection() -> Bool {
        guard !isSelectionEnabled else { return canSelect }
        
        isSelectionEnabled = true
        
        let audios = audios.map { $0.deselected() }
        self.audios = audios
        
        return canSelect
    }
    
    @discardableResult
    public func disableSelection() -> Bool {
        guard isSelectionEnabled else { return canSelect }
        
        isSelectionEnabled = false
        
        let audios = audios.map { $0.noSelection() }
        self.audios = audios
        
        return canSelect
    }
    
    public func toggleRingtoneAudioSelection(_ audio: RingtoneAudio) {
        guard let isSelected = audio.isSelected else { return }
        
        if isSelected {
            guard let index = audios.firstIndex(where: { audio.id == $0.id })
            else { return }
            
            audios[index] = audio.deselected()
        } else {
            guard let index = audios.firstIndex(where: { audio.id == $0.id })
            else { return }
            
            audios[index] = audio.selected()
        }
    }
    
    public func selectAllRingtoneAudios() {
        let selectedAudios = audios.map { $0.selected() }
        self.audios = selectedAudios
    }
    
    public func deselectAllRingtoneAudios() {
        let deselectedAudios = audios.map { $0.deselected() }
        self.audios = deselectedAudios
    }
    
    public func deleteRingtoneAudios(_ audios: [RingtoneAudio]) {
        // TODO: Delete audios from the repository.
        // TODO: Sync views.
        
        guard !audios.isEmpty else { return }
        
        var currentAudios = self.audios
        
        for audio in audios {
            guard let index = currentAudios.firstIndex(where: { audio.id == $0.id })
            else { continue }
            currentAudios.remove(at: index)
        }
        
        self.audios = currentAudios
    }
}

// MARK: - Get Created Ringtones
extension RingtoneCreatedViewModel {
    private func getCreatedRingtoneAudios() {
        audioRepository.getCreatedRingtoneAudios()
            .sink { completion in
                guard case .failure(let error) = completion else { return }
                print(error)
            } receiveValue: { [weak self] audios in
                guard let self = self else { return }
                
                var audios = audios
                
                // Syncing playback status.
                if let currentAudioID = self.audioPlayer.currentAudioID,
                   let index = audios.firstIndex(where: { $0.id == currentAudioID }) {
                    audios[index] = audios[index].played()
                }
                
                self.audios = audios
            }
            .store(in: &cancellables)
    }
}

// MARK: - Import
extension RingtoneCreatedViewModel {
    public func importRingtoneAudio() {
        action = .importAudio
    }
    
    private func observeImportedAudios() {
        audioImportResponder.audiosPublisher
            .sink { [weak self] audios in
                guard let self = self else { return }
                
                self.audios.append(contentsOf: audios)
            }
            .store(in: &cancellables)
        
        audioImportResponder.isLoadingPublisher
            .sink { [weak self] isLoading in
                guard let self = self else { return }
                self.isLoading = isLoading
            }
            .store(in: &cancellables)
    }
}

// MARK: - Sync Favorite Audios
extension RingtoneCreatedViewModel {
    private func observeFavoriteAudios() {
        audioFavoriteStatusChangeResponder.audiosPublisher
            .sink { [weak self] favoriteAudios in
                guard let self = self else { return }
                
                var audios = self.audios
                
                for (index, audio) in audios.enumerated() {
                    if let favoriteIndex = favoriteAudios.firstIndex(where: { audio.id == $0.id }) {
                        audios[index] = favoriteAudios[favoriteIndex]
                    } else {
                        audios[index] = audio.unliked()
                    }
                }
                
                self.audios = audios
            }
            .store(in: &cancellables)
    }
}

// MARK: - RingtoneAudioPlaybackStatusChangeResponder
extension RingtoneCreatedViewModel: RingtoneAudioPlaybackStatusChangeResponder {
    public func changeRingtoneAudioPlaybackStatus(_ audio: RingtoneAudio) {
        if audio.isPlaying {
            audioPlayer.pause()
        } else {
            audioPlayer.play(audio)
        }
    }
    
    private func observeAudioPlayerStatus() {
        audioPlayer.statusPublisher
            .sink { [weak self] status in
                guard let self = self else { return }
                
                switch status {
                case .startedPlaying(let audioID):
                    var audios = self.audios
                    
                    // TODO: Optimize.
                    for (index, audio) in self.audios.enumerated() {
                        if audioID == audio.id  {
                            audios[index] = audios[index].played()
                        } else {
                            audios[index] = audios[index].paused()
                        }
                    }
                    
                    self.audios = audios
                case .pausedPlaying:
                    self.audios = self.audios.map { $0.paused() }
                case .finishedPlaying:
                    self.audios = self.audios.map { $0.paused() }
                case .failedToPlay:
                    self.audios = self.audios.map { $0.paused() }
                case .failedToInitialize(_):
                    self.audios = self.audios.map { $0.paused() }
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Export
extension RingtoneCreatedViewModel: RingtoneAudioExportResponder {
    public func exportRingtoneAudio(_ audio: RingtoneAudio) {
        exportRingtoneAudios([audio])
    }
    
    public func exportRingtoneAudios(_ audios: [RingtoneAudio]) {
        let dataExporter = dataExporterFactory()
        
        return dataExporter.exportRingtoneAudios(audios)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self = self else { return }
                
                let urls = result.completeItems.map { $0.url }
                
                self.action = .exportGarageBandProjects(urls)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Edit
extension RingtoneCreatedViewModel: RingtoneAudioEditResponder {
    public func editRingtoneAudio(_ audio: RingtoneAudio) {
        action = .editAudio(audio)
    }
}
