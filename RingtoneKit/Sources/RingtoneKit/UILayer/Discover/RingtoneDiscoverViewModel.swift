//
//  RingtoneDiscoverViewModel.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 22.02.25.
//

import Combine

public protocol RingtoneDiscoverViewModelFactory {
    func makeRingtoneDiscoverViewModel() -> RingtoneDiscoverViewModel
}

public final class RingtoneDiscoverViewModel {
    // MARK: - Properties
    @Published public private(set) var action: RingtoneDiscoverAction?
    @Published public private(set) var categories: [RingtoneCategory] = []
    @Published public private(set) var audios: [RingtoneAudio] = []
    
    private var cancellables: Set<AnyCancellable> = []
    
    private let discoverAudiosMediator: RingtoneDiscoverAudiosMediator
    private let categoreisRepository: IRingtoneCategoriesRepository
    private let audioPlayer: IRingtoneAudioPlayer
    private let dataExporterFactory: () -> IRingtoneDataExporter
    
    // MARK: - Methods
    public init(
        audioPlayer: IRingtoneAudioPlayer,
        discoverAudiosMediator: RingtoneDiscoverAudiosMediator,
        categoreisRepository: IRingtoneCategoriesRepository,
        dataExporterFactory: @escaping () -> IRingtoneDataExporter
    ) {
        self.audioPlayer = audioPlayer
        self.discoverAudiosMediator = discoverAudiosMediator
        self.categoreisRepository = categoreisRepository
        self.dataExporterFactory = dataExporterFactory
        
        getCategories()
        observeDiscoverAudios()
    }
    
    private func getCategories() {
        categoreisRepository.getCategories()
            .sink { completion in
                guard case .failure(let error) = completion else { return }
                print(error)
            } receiveValue: { [weak self] categories in
                guard let self = self else { return }
                self.categories = categories
            }
            .store(in: &cancellables)
    }
    
    private func observeDiscoverAudios() {
        discoverAudiosMediator.discoverAudiosPublisher
            .sink { [weak self] discoverAudios in
                guard let self = self else { return }
                
                self.audios = discoverAudios
            }
            .store(in: &cancellables)
    }
}

// MARK: - Favorite
extension RingtoneDiscoverViewModel: RingtoneAudioFavoriteStatusChangeResponder {
    public func changeAudioFavoriteStatus(_ audio: RingtoneAudio) {
        discoverAudiosMediator.changeAudioFavoriteStatus(audio)
    }
}

// MARK: - Edit
extension RingtoneDiscoverViewModel: RingtoneAudioEditResponder {
    public func editRingtoneAudio(_ audio: RingtoneAudio) {
        action = .editAudio(audio)
    }
}

// MARK: - Export
extension RingtoneDiscoverViewModel: RingtoneAudioExportResponder {
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

// MARK: - Category
extension RingtoneDiscoverViewModel: RingtoneAudioCategorySelectionResponder {
    public func selectCategory(_ category: RingtoneCategory) {
        discoverAudiosMediator.selectCategory(category)
    }
}

// MARK: - Playback
extension RingtoneDiscoverViewModel: RingtoneAudioPlaybackStatusChangeResponder {
    public func changeRingtoneAudioPlaybackStatus(_ audio: RingtoneAudio) {
        if audio.isPlaying {
            audioPlayer.pause()
        } else {
            audioPlayer.play(audio)
        }
    }
}
