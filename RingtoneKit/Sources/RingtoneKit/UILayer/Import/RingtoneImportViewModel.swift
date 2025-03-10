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
    private let dataImporterFactory: (_ isRemote: Bool) -> IRingtoneDataImporter
    private let dataConverterFactory: () -> IRingtoneDataConverter
    
    // MARK: - Methods
    public init(
        audioRepository: IRingtoneAudioRepository,
        dataImporterFactory: @escaping (_ isRemote: Bool) -> IRingtoneDataImporter,
        dataConverterFactory: @escaping () -> IRingtoneDataConverter
    ) {
        self.audioRepository = audioRepository
        self.dataImporterFactory = dataImporterFactory
        self.dataConverterFactory = dataConverterFactory
    }
    
    public func createRingtoneItemsFromItemProviders(_ itemProviders: [NSItemProvider]) {
        let dataImporter = dataImporterFactory(false)
        let dataConverter = dataConverterFactory()
        
        isloadingSubject.send(true)
        
        dataImporter.importDataFromItemProviders(itemProviders)
            .sink { [weak self] items in
                guard let self = self else { return }
                
                let localItems = items.filter { !$0.isRemote }
                let urls = localItems.compactMap { try? $0.result.get() }
                
                dataConverter.convertToRingtoneAudios(urls)
                    .sink { result in
                        
                        self.audioRepository.addRingtoneAudios(result.audios)
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
    
    public func createRingtoneItemsFromURLs(_ urls: [URL]) {
        let dataImporter = dataImporterFactory(false)
        let dataConverter = dataConverterFactory()
        
        isloadingSubject.send(true)
        
        dataImporter.importDataFromURLs(urls)
            .sink { [weak self] items in
                guard let self = self else { return }
                
                let localItems = items.filter { !$0.isRemote }
                let urls = localItems.compactMap { try? $0.result.get() }
                
                dataConverter.convertToRingtoneAudios(urls)
                    .sink { result in
                        
                        print("convertToRingtoneAudios", result.errors)
                        
                        self.audioRepository.addRingtoneAudios(result.audios)
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
}
