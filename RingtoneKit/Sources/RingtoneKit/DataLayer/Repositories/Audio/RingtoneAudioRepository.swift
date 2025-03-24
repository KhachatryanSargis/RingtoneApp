//
//  RingtoneAudioRepository.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 27.02.25.
//

import Foundation
import Combine

public final class RingtoneAudioRepository: IRingtoneAudioRepository {
    // MARK: - Properties
    @Published private var discoverAudios: [RingtoneAudio] = []
    @Published private var favoriteAudios: [RingtoneAudio] = []
    @Published private var createdAudios: [RingtoneAudio] = []
    
    private var cancellables: Set<AnyCancellable> = []
    
    private let store: IRingtoneAudioStore
    
    // MARK: - Methods
    public init(store: IRingtoneAudioStore) {
        self.store = store
        
        getCreatedRingtoneAudios()
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .sink { completion in
                guard case .failure(let error) = completion else { return }
                
                print(error)
            } receiveValue: { _ in }
            .store(in: &cancellables)
        
        getFavoriteRingtoneAudios()
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .sink { completion in
                guard case .failure(let error) = completion else { return }
                
                print(error)
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    public func addRingtoneAudios(_ audios: [RingtoneAudio]) -> AnyPublisher<[RingtoneAudio], RingtoneAudioRepositoryError> {
        store.addRingtoneAudios(audios)
            .map { [weak self] createdAudios in
                guard let self = self else { return audios }
                
                self.createdAudios.append(contentsOf: audios)
                
                return audios
            }
            .mapError { .storeError($0) }
            .eraseToAnyPublisher()
    }
    
    public func deleteRingtoneAudios(_ audios: [RingtoneAudio]) -> AnyPublisher<[RingtoneAudio], RingtoneAudioRepositoryError> {
        store.deleteRingtoneAudios(audios)
            .map { [weak self] deletedAudios in
                guard let self = self else { return deletedAudios }
                
                var currentFavoriteAudios: [RingtoneAudio] = self.favoriteAudios
                var currentCreatedAudios: [RingtoneAudio] = self.createdAudios
                
                for audio in deletedAudios {
                    if let favoriteIndex = currentFavoriteAudios.firstIndex(where: { audio.id == $0.id }) {
                        currentFavoriteAudios.remove(at: favoriteIndex)
                    }
                    
                    if let createdIndex = currentCreatedAudios.firstIndex(where: { audio.id == $0.id }) {
                        currentCreatedAudios.remove(at: createdIndex)
                    }
                }
                
                self.favoriteAudios = currentFavoriteAudios
                self.createdAudios = currentCreatedAudios
                
                return deletedAudios
            }
            .mapError { .storeError($0) }
            .eraseToAnyPublisher()
    }
    
    public func getRingtoneAudiosInCategory(_ category: RingtoneCategory) -> AnyPublisher<[RingtoneAudio], RingtoneAudioRepositoryError> {
        store.getRingtoneAudiosInCategory(category)
            .map { [weak self] discoverAudios in
                guard let self = self else { return discoverAudios }
                
                self.discoverAudios = discoverAudios
                
                return discoverAudios
            }
            .mapError { .storeError($0) }
            .eraseToAnyPublisher()
    }
    
    public func getFavoriteRingtoneAudios() -> AnyPublisher<[RingtoneAudio], RingtoneAudioRepositoryError> {
        store.getFavoriteRingtoneAudios()
            .map { [weak self] favoriteAudios in
                guard let self = self else { return favoriteAudios }
                
                self.favoriteAudios = favoriteAudios
                
                return favoriteAudios
            }
            .mapError { .storeError($0) }
            .eraseToAnyPublisher()
    }
    
    public func getCreatedRingtoneAudios() -> AnyPublisher<[RingtoneAudio], RingtoneAudioRepositoryError> {
        store.getCreatedRingtoneAudios()
            .map { [weak self] createdAudios in
                guard let self = self else { return createdAudios }
                
                self.createdAudios = createdAudios
                
                return createdAudios
            }
            .mapError { .storeError($0) }
            .eraseToAnyPublisher()
    }
    
    public func toggleRingtoneAudioFavoriteStatus(_ audio: RingtoneAudio) -> AnyPublisher<RingtoneAudio, RingtoneAudioRepositoryError> {
        store.toggleRingtoneAudioFavoriteStatus(audio)
            .map { [weak self] audio in
                guard let self = self else { return audio }
                
                if let index = self.favoriteAudios.firstIndex(where: { audio.id == $0.id }) {
                    self.favoriteAudios.remove(at: index)
                } else {
                    self.favoriteAudios.append(audio)
                }
                
                if let index = self.createdAudios.firstIndex(where: { audio.id == $0.id }) {
                    self.createdAudios[index] = audio
                }
                
                if let index = self.discoverAudios.firstIndex(where: { audio.id == $0.id }) {
                    self.discoverAudios[index] = audio
                }
                
                return audio
            }
            .mapError { .storeError($0) }
            .eraseToAnyPublisher()
    }
}

// MARK: - RingtoneDiscoverAudiosMediator
extension RingtoneAudioRepository: RingtoneDiscoverAudiosMediator {
    public var discoverAudiosPublisher: AnyPublisher<[RingtoneAudio], Never> {
        $discoverAudios.eraseToAnyPublisher()
    }
    
    public func enableDiscoverAudiosSelection() {
        deselectAllDiscoverAudios()
    }
    
    public func disableDiscoverAudiosSelection() {
        discoverAudios = discoverAudios.map { $0.noSelection() }
    }
    
    public func toggleDiscoverAudioSelection(_ audio: RingtoneAudio) {
        guard let isSelected = audio.isSelected,
              let index = discoverAudios.firstIndex(where: { $0.id == audio.id })
        else { return }
        
        discoverAudios[index] = isSelected ? audio.deselected() : audio.selected()
    }
    
    public func selectAllDiscoverAudios() {
        discoverAudios = discoverAudios.map { $0.selected() }
    }
    
    public func deselectAllDiscoverAudios() {
        discoverAudios = discoverAudios.map { $0.deselected() }
    }
    
    public func selectCategory(_ category: RingtoneCategory) {
        getRingtoneAudiosInCategory(category)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .sink { completion in
                guard case .failure(let error) = completion else { return }
                
                print(error)
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
}

// MARK: - RingtoneFavoriteAudiosMediator
extension RingtoneAudioRepository: RingtoneFavoriteAudiosMediator {
    public var favoriteAudiosPublisher: AnyPublisher<[RingtoneAudio], Never> {
        $favoriteAudios.eraseToAnyPublisher()
    }
    
    public func enableFavoriteAudiosSelection() {
        deselectAllFavoriteAudios()
    }
    
    public func disableFavoriteAudiosSelection() {
        favoriteAudios = favoriteAudios.map { $0.noSelection() }
    }
    
    public func toggleFavoriteAudioSelection(_ audio: RingtoneAudio) {
        guard let isSelected = audio.isSelected,
              let index = favoriteAudios.firstIndex(where: { $0.id == audio.id })
        else { return }
        
        favoriteAudios[index] = isSelected ? audio.deselected() : audio.selected()
    }
    
    public func selectAllFavoriteAudios() {
        favoriteAudios = favoriteAudios.map { $0.selected() }
    }
    
    public func deselectAllFavoriteAudios() {
        favoriteAudios = favoriteAudios.map { $0.deselected() }
    }
}

// MARK: - RingtoneCreatedAudiosMediator
extension RingtoneAudioRepository: RingtoneCreatedAudiosMediator {
    public var createdAudiosPublisher: AnyPublisher<[RingtoneAudio], Never> {
        $createdAudios.eraseToAnyPublisher()
    }
    
    public func enableCreatedAudiosSelection() {
        deselectAllCreatedAudios()
    }
    
    public func disableCreatedAudiosSelection() {
        createdAudios = createdAudios.map { $0.noSelection() }
    }
    
    public func toggleCreatedAudioSelection(_ audio: RingtoneAudio) {
        guard let isSelected = audio.isSelected,
              let index = createdAudios.firstIndex(where: { $0.id == audio.id })
        else { return }
        
        createdAudios[index] = isSelected ? audio.deselected() : audio.selected()
    }
    
    public func selectAllCreatedAudios() {
        createdAudios = createdAudios.map { $0.selected() }
    }
    
    public func deselectAllCreatedAudios() {
        createdAudios = createdAudios.map { $0.deselected() }
    }
    
    public func addRingtoneAudios(_ audios: [RingtoneAudio]) {
        addRingtoneAudios(audios)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .sink { completion in
                guard case .failure(let error) = completion else { return }
                
                print(error)
            } receiveValue: { _ in}
            .store(in: &cancellables)
    }
    
    public func deleteRingtoneAudios(_ audios: [RingtoneAudio]) {
        deleteRingtoneAudios(audios)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .sink { completion in
                guard case .failure(let error) = completion else { return }
                
                print(error)
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
}

// MARK: - Favorite
// This function is present in all mediators.
extension RingtoneAudioRepository: RingtoneAudioFavoriteStatusChangeResponder {
    public func changeAudioFavoriteStatus(_ audio: RingtoneAudio) {
        toggleRingtoneAudioFavoriteStatus(audio)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .sink { completion in
                guard case .failure(let error) = completion else { return }
                
                print(error)
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
}
