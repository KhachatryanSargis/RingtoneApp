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
    private var cancellables: Set<AnyCancellable> = []
    private let categoreisRepository: IRingtoneCategoriesRepository
    
    // MARK: - Methods
    public init(categoreisRepository: IRingtoneCategoriesRepository) {
        self.categoreisRepository = categoreisRepository
    }
    
    public func getCategories() {
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
}
