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
    
    public var downloadResultPublisher = PassthroughSubject<RingtoneDataDownloaderResult, Never>()
    
    private var importCancellables = Set<AnyCancellable>()
    private var downloadCancellables = Set<AnyCancellable>()
    private var convertCancellables = Set<AnyCancellable>()
    
    private var failedImporterItems: [RingtoneDataImporterFailedItem] = []
    private var failedConverterItems: [RingtoneDataConverterFailedItem] = []
    
    private let dataImporterFactory: () -> IRingtoneDataImporter
    private let dataDownloaderFactory: (_ url: URL) -> IRingtoneDataDownloader
    private let dataConverterFactory: () -> IRingtoneDataConverter
    
    // MARK: - Methods
    public init(
        dataImporterFactory: @escaping () -> IRingtoneDataImporter,
        dataDownloaderFactory: @escaping (_ url: URL) -> IRingtoneDataDownloader,
        dataConverterFactory: @escaping () -> IRingtoneDataConverter
    ) {
        self.dataImporterFactory = dataImporterFactory
        self.dataDownloaderFactory = dataDownloaderFactory
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
                    .store(in: &self.convertCancellables)
            }
            .store(in: &importCancellables)
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
                    .store(in: &convertCancellables)
            }
            .store(in: &importCancellables)
    }
    
    public func downloadFromUrl(_ url: URL) -> AnyPublisher<Progress, Never> {
        let dataDownloader = dataDownloaderFactory(url)
        let dataConverter = dataConverterFactory()
        
        dataDownloader.download(url: url)
            .sink(receiveValue: { [weak self] downloaderResult in
                guard let self = self else { return }
                
                switch downloaderResult {
                case .complete(let item):
                    self.isLoadingSubject.send(true)
                    
                    dataConverter.convertDataDownloaderCompleteItems([item])
                        .sink { converterResult in
                            
                            self.processConverterResult(converterResult)
                            
                            self.isLoadingSubject.send(false)
                        }
                        .store(in: &convertCancellables)
                    
                    self.downloadResultPublisher.send(.complete(item))
                case .failed(let item):
                    self.downloadResultPublisher.send(.failed(item))
                }
            })
            .store(in: &downloadCancellables)
        
        return dataDownloader.progressPublisher
    }
    
    public func cancelCurrentDownloads() {
        downloadCancellables.forEach { $0.cancel() }
        downloadCancellables.removeAll()
    }
}

// MARK: - Process Results
extension RingtoneImportViewModel {
    private func processImporterResult(_ result: RingtoneDataImporterResult) -> [RingtoneDataImporterCompleteItem] {
        let failedItems = result.failedItems
        self.failedImporterItems.append(contentsOf: failedItems)
        
        let failedAudios = failedItems.map { RingtoneAudio.importFailed(item: $0) }
        
        audiosSubject.send(failedAudios)
        
        return result.completeItems
    }
    
    private func processConverterResult(_ result: RingtoneDataConverterResult) {
        let failedItems = result.failedItems
        self.failedConverterItems.append(contentsOf: failedItems)
        
        let failedAudios = failedItems.map { RingtoneAudio.conversionFailed(item: $0) }
        
        let completeItems = result.completeItems
        
        let completeAudios = completeItems.map {
            RingtoneAudio.init(
                id: $0.id.uuidString,
                title: $0.name,
                desciption: $0.description,
                url: $0.url,
                waveformURL: $0.waveformURL
            )
        }
        
        audiosSubject.send(completeAudios + failedAudios)
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
        if audio.failedToImport {
            guard let failedIndex = failedImporterItems.firstIndex(where: { $0.id.uuidString == audio.id })
            else { return }
            
            let failedItem = failedImporterItems[failedIndex]
            failedImporterItems.remove(at: failedIndex)
            
            retryFailedImporterItems([failedItem])
        } else if audio.failedToConvert {
            guard let failedIndex = failedConverterItems.firstIndex(where: { $0.id.uuidString == audio.id })
            else { return }
            
            let failedItem = failedConverterItems[failedIndex]
            failedConverterItems.remove(at: failedIndex)
            
            retryFailedConverterItems([failedItem])
        }
    }
    
    public func retryFailedRingtoneAudios() {
        let failedImporterItems = failedImporterItems
        self.failedImporterItems.removeAll()
        
        retryFailedImporterItems(failedImporterItems)
        
        let failedConverterItems = self.failedConverterItems
        self.failedConverterItems.removeAll()
        
        retryFailedConverterItems(failedConverterItems)
    }
    
    public func clearFailedRingtoneAudios() {
        failedImporterItems.removeAll()
        failedConverterItems.removeAll()
    }
    
    public func cleanFailedRingtoneAudio(_ audio: RingtoneAudio) {
        failedImporterItems.removeAll(where: { $0.id.uuidString == audio.id })
        failedConverterItems.removeAll(where: { $0.id.uuidString == audio.id })
    }
}

// MARK: - Retry Failed Importer Items
extension RingtoneImportViewModel {
    private func retryFailedImporterItems(_ items: [RingtoneDataImporterFailedItem]) {
        guard !items.isEmpty else { return }
        
        var itemProviders: [NSItemProvider] = []
        var urls: [URL] = []
        
        for item in items {
            switch item.source {
            case .gallery(let itemProvider):
                itemProviders.append(itemProvider)
            case .documents(let url):
                urls.append(url)
            }
        }
        
        if !itemProviders.isEmpty {
            importDataFromGallery(itemProviders)
        }
        
        if !urls.isEmpty {
            importDataFromDocuments(urls)
        }
    }
}

// MARK: - Retry Failed Converter Items
extension RingtoneImportViewModel {
    private func retryFailedConverterItems(_ items: [RingtoneDataConverterFailedItem]) {
        guard !items.isEmpty else { return }
        
        var downloaderItems: [RingtoneDataDownloaderCompleteItem] = []
        var importerItems: [RingtoneDataImporterCompleteItem] = []
        
        for item in items {
            switch item.souce {
            case .importerItem(let importerItem):
                importerItems.append(importerItem)
            case .downloaderItem(let downloaderItem):
                downloaderItems.append(downloaderItem)
            }
        }
        
        if !importerItems.isEmpty {
            let dataConverter = dataConverterFactory()
            
            isLoadingSubject.send(true)
            
            dataConverter.convertDataImporterCompleteItems(importerItems)
                .sink { converterResult in
                    
                    self.processConverterResult(converterResult)
                    
                    self.isLoadingSubject.send(false)
                }
                .store(in: &convertCancellables)
        }
        
        if !downloaderItems.isEmpty {
            let dataConverter = dataConverterFactory()
            
            isLoadingSubject.send(true)
            
            dataConverter.convertDataDownloaderCompleteItems(downloaderItems)
                .sink { converterResult in
                    
                    self.processConverterResult(converterResult)
                    
                    self.isLoadingSubject.send(false)
                }
                .store(in: &convertCancellables)
        }
    }
}
