//
//  RingtoneSettingsViewModel.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 10.05.25.
//

import Foundation

public protocol RingtoneSettingsViewModelFactory {
    func makeSettingsViewModel() -> RingtoneSettingsViewModel
}

public final class RingtoneSettingsViewModel {
    // MARK: - Methods
    public init() {}
    
    // MARK: - Properties
    @Published private(set) public var actions = RingtoneSettingsAction.allCases
}
