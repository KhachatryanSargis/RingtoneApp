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

public final class RingtoneImportViewModel: @unchecked Sendable {
    // MARK: - Properties
    private let audiosSubject = PassthroughSubject<[RingtoneAudio], Never>()
    private var importedAudios: [RingtoneAudio] = []
    private var cancellables: Set<AnyCancellable> = []
    private let audioEditor: IRingtoneAudioEditor
    private let audioRepository: IRingtoneAudioRepository
    
    // MARK: - Methods
    public init(
        audioEditor: IRingtoneAudioEditor,
        audioRepository: IRingtoneAudioRepository
    ) {
        self.audioEditor = audioEditor
        self.audioRepository = audioRepository
    }
    
    public func createRingtoneItemsFromItemProviders(_ itemProviders: [NSItemProvider]) {
        let lock = NSLock()
        let group = DispatchGroup()
        
        for itemProvider in itemProviders {
            guard let typeIdentifier = itemProvider.registeredTypeIdentifiers.first,
                  let utType = UTType(typeIdentifier),
                  utType.conforms(to: .movie)
            else { continue }
            
            group.enter()
            
            let suggestedName = itemProvider.suggestedName
            
            itemProvider.loadItem(forTypeIdentifier: typeIdentifier) { [weak self, suggestedName] url, error in
                guard let self = self
                else {
                    print("lost reference to self")
                    
                    group.leave()
                    return
                }
                
                if let error = error {
                    print(error)
                    
                    group.leave()
                    return
                }
                
                guard let url = url as? URL
                else {
                    print("failed to get the url")
                    
                    group.leave()
                    return
                }
                
                let fileName: String
                if utType.conforms(to: .mpeg4Movie) {
                    fileName = UUID().uuidString + ".mp4"
                } else {
                    fileName = UUID().uuidString + ".mov"
                }
                
                let destination = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
                
                do {
                    try FileManager.default.copyItem(at: url, to: destination)
                    self.audioEditor.convertToAudioRingtone(destination, suggestedName: suggestedName)
                        .sink { completion in
                            guard case .failure(let error) = completion else { return }
                            print(error)
                            
                            group.leave()
                        } receiveValue: { audio in
                            lock.lock()
                            self.importedAudios.append(audio)
                            lock.unlock()
                            
                            group.leave()
                        }
                        .store(in: &cancellables)
                } catch {
                    print(destination, error)
                    
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .global()) { [weak self] in
            guard let self = self else { return }
            
            self.audioRepository.addRingtoneAudios(importedAudios)
                .sink { completion in
                    guard case .failure(let error) = completion else { return }
                    print(error)
                    
                    for audio in self.importedAudios {
                        do {
                            try FileManager.default.removeItem(at: audio.url)
                        } catch {
                            print(error)
                        }
                    }
                } receiveValue: { audios in
                    self.audiosSubject.send(audios)
                    self.importedAudios = []
                }
                .store(in: &cancellables)
        }
    }
}

// MARK: - RingtoneAudioImportResponder
extension RingtoneImportViewModel: RingtoneAudioImportResponder {
    public var audiosPublisher: AnyPublisher<[RingtoneAudio], Never> {
        audiosSubject.eraseToAnyPublisher()
    }
}
