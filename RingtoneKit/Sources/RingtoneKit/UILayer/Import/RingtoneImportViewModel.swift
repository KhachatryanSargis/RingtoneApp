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
    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    private let audiosSubject = PassthroughSubject<[RingtoneAudio], Never>()
    private var cancellables: Set<AnyCancellable> = []
    
    private var failedImporterItems: [RingtoneDataImporterFailedItem] = []
    private var failedConverterItems: [RingtoneDataConverterFailedItem] = []
    private var failedAudios: [RingtoneAudio] = []
    
    private let dataImporterFactory: () -> IRingtoneDataImporter
    private let dataConverterFactory: () -> IRingtoneDataConverter
    
    // MARK: - Methods
    public init(
        dataImporterFactory: @escaping () -> IRingtoneDataImporter,
        dataConverterFactory: @escaping () -> IRingtoneDataConverter
    ) {
        self.dataImporterFactory = dataImporterFactory
        self.dataConverterFactory = dataConverterFactory
    }
    
    public func importDataFromGallery(_ itemProviders: [NSItemProvider]) {
        let dataImporter = dataImporterFactory()
        let dataConverter = dataConverterFactory()
        
        isLoadingSubject.send(true)
        
        dataImporter.importDataFromGallery(itemProviders)
            .sink { [weak self] importerResult in
                guard let self = self else { return }
                
                let imports = processImporterResult(importerResult)
                
                dataConverter.convertDataImporterCompleteItems(imports)
                    .sink { converterResult in
                        
                        self.processConverterResult(converterResult)
                        
                        self.isLoadingSubject.send(false)
                    }
                    .store(in: &self.cancellables)
            }
            .store(in: &cancellables)
    }
    
    public func importDataFromDocuments(_ urls: [URL]) {
        let dataImporter = dataImporterFactory()
        let dataConverter = dataConverterFactory()
        
        isLoadingSubject.send(true)
        
        dataImporter.importDataFromDocuments(urls)
            .sink { [weak self] importerResult in
                guard let self = self else { return }
                
                let imports = self.processImporterResult(importerResult)
                
                dataConverter.convertDataImporterCompleteItems(imports)
                    .sink { converterResult in
                        
                        self.processConverterResult(converterResult)
                        
                        self.isLoadingSubject.send(false)
                    }
                    .store(in: &cancellables)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Process Results
extension RingtoneImportViewModel {
    private func processImporterResult(_ result: RingtoneDataImporterResult) -> [RingtoneDataImporterCompleteItem] {
        let failedItems = result.failedItems
        self.failedImporterItems = failedItems
        
        let failedAudios = failedItems.map { RingtoneAudio.importFailed(item: $0) }
        self.failedAudios = failedAudios
        
        return result.completeItems
    }
    
    private func processConverterResult(_ result: RingtoneDataConverterResult) {
        let failedItems = result.failedItems
        self.failedConverterItems = failedItems
        
        let failedAudios = failedItems.map { RingtoneAudio.conversionFailed(item: $0) }
        self.failedAudios.append(contentsOf: failedAudios)
        
        let completeItems = result.completeItems
        
        let completeAudios = completeItems.map {
            RingtoneAudio.init(
                id: $0.id.uuidString,
                title: $0.name,
                desciption: $0.description,
                url: $0.url
            )
        }
        
        audiosSubject.send(completeAudios + self.failedAudios)
        
        self.failedAudios = []
    }
}

// MARK: - RingtoneAudioImportResponder
extension RingtoneImportViewModel: RingtoneAudioImportResponder {
    public var importedAudiosPublisher: AnyPublisher<[RingtoneAudio], Never> {
        audiosSubject.eraseToAnyPublisher()
    }
    
    public var isLoadingPublisher: AnyPublisher<Bool, Never> {
        isLoadingSubject.eraseToAnyPublisher()
    }
    
    
    public func retryFailedRingtoneAudio(_ audio: RingtoneAudio) {
        
    }
    
    public func retryFailedRingtoneAudios() {
        
    }
    
    public func clearFailedRingtoneAudios() {
        failedImporterItems = []
        failedConverterItems = []
    }
    
    public func cleanFailedRingtoneAudio(_ audio: RingtoneAudio) {
        failedImporterItems.removeAll(where: { $0.id.uuidString == audio.id })
        failedConverterItems.removeAll(where: { $0.id.uuidString == audio.id })
    }
}
