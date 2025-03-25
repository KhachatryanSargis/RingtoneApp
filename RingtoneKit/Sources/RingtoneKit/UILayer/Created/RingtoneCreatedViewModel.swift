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
    
    private let audioPlayer: IRingtoneAudioPlayer
    private let createdAudiosMediator: RingtoneCreatedAudiosMediator
    private let audioImportResponder: RingtoneAudioImportResponder
    private let dataExporterFactory: () -> IRingtoneDataExporter
    
    // MARK: - Methods
    public init(
        audioPlayer: IRingtoneAudioPlayer,
        createdAudiosMediator: RingtoneCreatedAudiosMediator,
        audioImportResponder: RingtoneAudioImportResponder,
        dataExporterFactory: @escaping () -> IRingtoneDataExporter
    ) {
        self.audioPlayer = audioPlayer
        self.createdAudiosMediator = createdAudiosMediator
        self.audioImportResponder = audioImportResponder
        self.dataExporterFactory = dataExporterFactory
        
        observeCreatedAudios()
        observeAudioImportResponder()
        observeAudioPlayerStatus()
    }
    
    private func observeCreatedAudios() {
        createdAudiosMediator.createdAudiosPublisher
            .sink { [weak self] createdAudios in
                guard let self = self else { return }
                
                var audios = createdAudios
                
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

// MARK: - Selection
extension RingtoneCreatedViewModel: RingtoneAudioSelectionResponder {
    public func enableSelection() {
        guard !isSelectionEnabled else { return }
        
        isSelectionEnabled = true
        
        createdAudiosMediator.enableCreatedAudiosSelection()
    }
    
    public func disableSelection() {
        guard isSelectionEnabled else { return }
        
        isSelectionEnabled = false
        
        createdAudiosMediator.disableCreatedAudiosSelection()
    }
    
    public func toggleRingtoneAudioSelectionStatus(_ audio: RingtoneAudio) {
        createdAudiosMediator.toggleCreatedAudioSelection(audio)
    }
    
    public func selectAllRingtoneAudios() {
        createdAudiosMediator.selectAllCreatedAudios()
    }
    
    public func deselectAllRingtoneAudios() {
        createdAudiosMediator.deselectAllCreatedAudios()
    }
}

// MARK: - Favorite
extension RingtoneCreatedViewModel: RingtoneAudioFavoriteStatusChangeResponder {
    public func changeAudioFavoriteStatus(_ audio: RingtoneAudio) {
        createdAudiosMediator.changeAudioFavoriteStatus(audio)
    }
}

// MARK: - Edit
extension RingtoneCreatedViewModel: RingtoneAudioEditResponder {
    public func editRingtoneAudio(_ audio: RingtoneAudio) {
        action = .editAudio(audio)
    }
}

// MARK: - Delete
extension RingtoneCreatedViewModel: RingtoneAudioDeleteResponder {
    public func deleteRingtoneAudios(_ audios: [RingtoneAudio]) {
        createdAudiosMediator.deleteRingtoneAudios(audios)
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
            .sink { [weak self] result in
                guard let self = self else { return }
                
                let urls = result.completeItems.map { $0.url }
                
                self.action = .exportGarageBandProjects(urls)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Playback
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
                default:
                    self.audios = self.audios.map { $0.paused() }
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Import
extension RingtoneCreatedViewModel: RingtoneAudioImportResponder {
    public func importRingtoneAudio() {
        action = .importAudio
    }
    
    public var isLoadingPublisher: AnyPublisher<Bool, Never> {
        audioImportResponder.isLoadingPublisher
    }
    
    public var importedAudiosPublisher: AnyPublisher<[RingtoneAudio], Never> {
        audioImportResponder.importedAudiosPublisher
    }
    
    public func clearFailedRingtoneAudios() {
        audioImportResponder.clearFailedRingtoneAudios()
    }
    
    public func retryFailedRingtoneAudio(_ audio: RingtoneAudio) {
        audioImportResponder.cleanFailedRingtoneAudio(audio)
    }
    
    public func retryFailedRingtoneAudios() {
        audioImportResponder.retryFailedRingtoneAudios()
    }
    
    public func cleanFailedRingtoneAudio(_ audio: RingtoneAudio) {
        audioImportResponder.retryFailedRingtoneAudio(audio)
    }
    
    private func observeAudioImportResponder() {
        audioImportResponder.isLoadingPublisher
            .sink { [weak self] isLoading in
                guard let self = self else { return }
                self.isLoading = isLoading
            }
            .store(in: &cancellables)
        
        audioImportResponder.importedAudiosPublisher
            .sink { [weak self] importedAudios in
                guard let self = self else { return }
                
                let failedAudios = importedAudios.filter { $0.isFailed == true }
                self.audios.append(contentsOf: failedAudios)
                
                let successAudios = importedAudios.filter { $0.isFailed == false }
                self.createdAudiosMediator.addRingtoneAudios(successAudios)
            }
            .store(in: &cancellables)
    }
}
