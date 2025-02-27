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
    @Published public private(set) var categories: [RingtoneCategory] = []
    @Published public private(set) var audios: [RingtoneAudio] = []
    
    private var cancellables: Set<AnyCancellable> = []
    private let categoreisRepository: IRingtoneCategoriesRepository
    private let audioRepository: IRingtoneAudioRepository
    
    // MARK: - Methods
    public init(
        categoreisRepository: IRingtoneCategoriesRepository,
        audioRepository: IRingtoneAudioRepository
    ) {
        self.categoreisRepository = categoreisRepository
        self.audioRepository = audioRepository
        getCategories()
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
    
    private func getRingtoneAudiosInCategory(_ category: RingtoneCategory) {
        audioRepository.getRingtoneAudiosInCategory(category)
            .sink { completion in
                guard case .failure(let error) = completion else { return }
                print(error)
            } receiveValue: { [weak self] audios in
                guard let self = self else { return }
                self.audios = audios
            }
            .store(in: &cancellables)
    }
}

// MARK: - RingtoneDiscoverCategorySelectionResponder
extension RingtoneDiscoverViewModel: RingtoneDiscoverCategorySelectionResponder {
    public func selectCategory(_ category: RingtoneCategory) {
        getRingtoneAudiosInCategory(category)
    }
}
