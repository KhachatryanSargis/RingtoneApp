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
    }
    
    private func observeCreatedAudios() {
        createdAudiosMediator.createdAudiosPublisher
            .sink { [weak self] createdAudios in
                guard let self = self else { return }
                
                self.audios = createdAudios
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

// MARK: - Save
extension RingtoneCreatedViewModel: RingtoneAudioDataChangeResponder {
    public func saveRingtoneAudio(_ audio: RingtoneAudio) {
        createdAudiosMediator.saveRingtoneAudio(audio)
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
        let dataExporter = dataExporterFactory()
        
        dataExporter.createGarageBandProject(from: audio)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                guard case .failure(let error) = completion else { return }
                
                print(error)
            } receiveValue: { [weak self] url in
                guard let self = self else { return }
                
                self.action = .exportGarageBandProject(url, audio)
            }
            .store(in: &cancellables)
    }
    
    public func exportRingtoneAudios(_ audios: [RingtoneAudio]) {
        action = .exportAudios(audios)
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
                
                self.createdAudiosMediator.addRingtoneAudios(importedAudios)
            }
            .store(in: &cancellables)
    }
}
