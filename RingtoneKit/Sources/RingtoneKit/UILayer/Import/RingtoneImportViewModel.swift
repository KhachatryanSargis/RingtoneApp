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
    private let audiosSubject = PassthroughSubject<[RingtoneAudio], Never>()
    private var cancellables: Set<AnyCancellable> = []
    
    private let audioRepository: IRingtoneAudioRepository
    private let dataImporterFactory: () -> IRingtoneDataImporter
    private let dataConverterFactory: () -> IRingtoneDataConverter
    
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
    
    public func createRingtoneItemsFromItemProviders(_ itemProviders: [NSItemProvider]) {
        let dataImporter = dataImporterFactory()
        let dataConverter = dataConverterFactory()
        
        dataImporter.importDataFromItemProviders(itemProviders)
            .sink { [weak self] result in
                guard let self = self else { return }
                
                print("importDataFromItemProviders", result.errors)
                
                dataConverter.convertToRingtoneAudios(result.urls)
                    .sink { result in
                        
                        print("convertToRingtoneAudios", result.errors)
                        
                        self.audiosSubject.send(result.audios)
                    }
                    .store(in: &cancellables)
            }
            .store(in: &cancellables)
    }
    
    public func createRingtoneItemsFromURLs(_ urls: [URL]) {
        let dataImporter = dataImporterFactory()
        let dataConverter = dataConverterFactory()
        
        dataImporter.importDataFromURLs(urls)
            .sink { [weak self] result in
                guard let self = self else { return }
                
                print("importDataFromURLs", result.errors)
                
                dataConverter.convertToRingtoneAudios(result.urls)
                    .sink { result in
                        
                        print("convertToRingtoneAudios", result.errors)
                        
                        self.audiosSubject.send(result.audios)
                    }
                    .store(in: &cancellables)
            }
            .store(in: &cancellables)
    }
}

// MARK: - RingtoneAudioImportResponder
extension RingtoneImportViewModel: RingtoneAudioImportResponder {
    public var audiosPublisher: AnyPublisher<[RingtoneAudio], Never> {
        audiosSubject.eraseToAnyPublisher()
    }
}
