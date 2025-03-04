//
//  ImportViewModel.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 04.03.25.
//

import Foundation
import Combine
import UniformTypeIdentifiers

public final class RingtoneImportViewModel: @unchecked Sendable {
    private var cancellables: Set<AnyCancellable> = []
    private let audioEditor = RingtoneAudioEditor()
    
    public func createRingtoneItemsFromItemProvider(_ itemProvider: NSItemProvider) {
        //        itemProviders.forEach {
        //            guard let typeIdentifier = $0.registeredTypeIdentifiers.first,
        //                  let utType = UTType(typeIdentifier) else { return }
        //            if utType.conforms(to: .movie) {
        //                var videoName = ""
        //                if let suggestedName = $0.suggestedName {
        //                    if utType.conforms(to: .mpeg4Movie) {
        //                        videoName = suggestedName + ".mp4"
        //                    } else {
        //                        videoName = suggestedName + ".mov"
        //                    }
        //                }
        //                let group = DispatchGroup()
        //                group.enter()
        //                $0.loadFileRepresentation(forTypeIdentifier: typeIdentifier) { [weak self] url, error in
        //                    guard let self, let url else { return }
        //                    if let error {
        //                        print(error.localizedDescription)
        //                    }
        //                    // copying file
        //                    let fm = FileManager.default
        //                    let destination = fm.temporaryDirectory.appendingPathComponent(videoName)
        //                    do {
        //                        try fm.copyItem(at: url, to: destination)
        //                    } catch {
        //                        print(error.localizedDescription)
        //                    }
        //
        //                    group.leave()
        //                    group.notify(queue: DispatchQueue.global()) {
        //                        // do staff with video
        //                        self.output.videoIsPicked(url: destination)
        //                    }
        //                }
        //            }
        
        guard let typeIdentifier = itemProvider.registeredTypeIdentifiers.first,
              let utType = UTType(typeIdentifier),
              utType.conforms(to: .movie)
        else { return }
        
        let videoName: String
        
        if utType.conforms(to: .mpeg4Movie) {
            videoName = UUID().uuidString + ".mp4"
        } else {
            videoName = UUID().uuidString + ".mov"
        }
        
        itemProvider.loadItem(forTypeIdentifier: typeIdentifier) { [weak self, videoName] url, error in
            guard let self = self
            else {
                print("no self")
                return
            }
            
            if let error = error {
                print (error)
                return
            }
            
            guard let url = url as? URL
            else { return }
            
            let fm = FileManager.default
            let destination = fm.temporaryDirectory.appendingPathComponent(videoName)
            
            do {
                try fm.copyItem(at: url, to: destination)
                self.audioEditor.convertToAudioRingtone(destination)
                    .sink { completion in
                        print(completion)
                    } receiveValue: { audio in
                        print(audio)
                    }
                    .store(in: &cancellables)
            } catch {
                print(destination, error)
            }
        }
    }
}
