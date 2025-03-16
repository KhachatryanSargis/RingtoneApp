//
//  RingtoneImportViewModel.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 04.03.25.
//

import Foundation
import Combine
import UniformTypeIdentifiers

public protocol RingtoneImportViewModelFactory {
    func makeRingtoneImportViewModel() -> RingtoneImportViewModel
}

public final class RingtoneImportViewModel {
    // MARK: - Properties
    private let isloadingSubject = PassthroughSubject<Bool, Never>()
    private let audiosSubject = PassthroughSubject<[RingtoneAudio], Never>()
    private var cancellables: Set<AnyCancellable> = []
    
    private let audioRepository: IRingtoneAudioRepository
    private let dataImporterFactory: () -> IRingtoneDataImporter
    private let dataConverterFactory: () -> IRingtoneDataConverter
    
    private var failedImporterItems: [RingtoneDataImporterFailedItem] = []
    private var failedConverterItems: [RingtoneDataConverterFailedItem] = []
    
    // MARK: - Methods
    public init(
        audioRepository: IRingtoneAudioRepository,
        dataImporterFactory: @escaping () -> IRingtoneDataImporter,
        dataConverterFactory: @escaping () -> IRingtoneDataConverter
    ) {
        self.audioRepository = audioRepository
        self.dataImporterFactory = dataImporterFactory
        self.dataConverterFactory = dataConverterFactory
    }
    
    public func importDataFromGallery(_ itemProviders: [NSItemProvider]) {
        let dataImporter = dataImporterFactory()
        let dataConverter = dataConverterFactory()
        
        isloadingSubject.send(true)
        
        dataImporter.importDataFromGallery(itemProviders)
            .sink { [weak self] importerResult in
                guard let self = self else { return }
                
                let imports = processImporterResult(importerResult)
                
                dataConverter.convertDataImporterCompleteItems(imports)
                    .sink { converterResult in
                        
                        let audios = self.processConverterResult(converterResult)
                        
                        self.audioRepository.addRingtoneAudios(audios)
                            .sink { completion in
                                self.isloadingSubject.send(false)
                                
                                guard case .failure(let error) = completion else { return }
                                
                                // TODO: Clean all the saved audio data if this fails.
                                print(error)
                            } receiveValue: { audios in
                                self.audiosSubject.send(audios)
                            }
                            .store(in: &self.cancellables)
                    }
                    .store(in: &self.cancellables)
            }
            .store(in: &cancellables)
    }
    
    public func importDataFromDocuments(_ urls: [URL]) {
        let dataImporter = dataImporterFactory()
        let dataConverter = dataConverterFactory()
        
        isloadingSubject.send(true)
        
        dataImporter.importDataFromDocuments(urls)
            .sink { [weak self] importerResult in
                guard let self = self else { return }
                
                let imports = self.processImporterResult(importerResult)
                
                dataConverter.convertDataImporterCompleteItems(imports)
                    .sink { converterResult in
                        
                        let audios = self.processConverterResult(converterResult)
                        
                        self.audioRepository.addRingtoneAudios(audios)
                            .sink { completion in
                                self.isloadingSubject.send(false)
                                
                                guard case .failure(let error) = completion else { return }
                                
                                // TODO: Clean all the saved audio data if this fails.
                                print(error)
                            } receiveValue: { audios in
                                self.audiosSubject.send(audios)
                            }
                            .store(in: &self.cancellables)
                    }
                    .store(in: &cancellables)
            }
            .store(in: &cancellables)
    }
}

// MARK: - RingtoneAudioImportResponder
extension RingtoneImportViewModel: RingtoneAudioImportResponder {
    public var isLoadingPublisher: AnyPublisher<Bool, Never> {
        isloadingSubject.eraseToAnyPublisher()
    }
    
    public var audiosPublisher: AnyPublisher<[RingtoneAudio], Never> {
        audiosSubject.eraseToAnyPublisher()
    }
    
    public func retryAll() {
        
    }
    
    public func retryByID(_ id: String) {
        
    }
    
    public func clearAll() {
        failedImporterItems = []
    }
    
    public func clearByID(_ id: String) {
        failedImporterItems.removeAll(where: { $0.id.uuidString == id })
    }
}

// MARK: - Process Results
extension RingtoneImportViewModel {
    private func processImporterResult(_ result: RingtoneDataImporterResult) -> [RingtoneDataImporterCompleteItem] {
        let failedItems = result.failedItems
        self.failedImporterItems = failedItems
        
        let failedAudios = failedItems.map { RingtoneAudio.importFailed(item: $0) }
        self.audiosSubject.send(failedAudios)
        
        return result.completeItems
    }
    
    private func processConverterResult(_ result: RingtoneDataConverterResult) -> [RingtoneAudio] {
        let failedItems = result.failedItems
        self.failedConverterItems = failedItems
        
        let failedAudios = failedItems.map { RingtoneAudio.conversionFailed(item: $0) }
        self.audiosSubject.send(failedAudios)
        
        let completeItems = result.completeItems
        
        let audios = completeItems.map {
            RingtoneAudio.init(
                id: $0.id.uuidString,
                title: $0.name,
                desciption: $0.description,
                url: $0.url
            )
        }
        
        return audios
    }
}
