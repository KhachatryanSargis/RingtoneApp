//
//  RingtoneCreatedViewModel.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 24.02.25.
//

import Foundation

public protocol RingtoneCreatedViewModelFactory {
    func makeRingtoneCreatedViewModel() -> RingtoneCreatedViewModel
}

public final class RingtoneCreatedViewModel {
    // MARK: - Properties
    @Published public private(set) var items: [Int] = []
    
    // MARK: - Mrthods
    public init () {}
}
