//
//  RingtoneUsageTutorialViewModel.swift
//  RingtoneKit
//
//  Created by Sargis Khachatryan on 05.05.25.
//

import Foundation

public protocol RingtoneUsageTutorialViewModelFactory {
    func createRingtoneUsageTutorialViewModelFactory() -> RingtoneUsageTutorialViewModel
}

public final class RingtoneUsageTutorialViewModel {
    // MARK: - Properties
    @Published private(set) public var steps: [RingtoneUsageTutorialStep] = [
        .init(
            title: "Open in GarageBand",
            description: "Share to GarageBand. Can't find it? Select the last option (More) and find GarageBand from Suggestions.",
            imageName: "usage_tutorial_step_1"
        ),
        .init(
            title: "Share your File",
            description: "When the file loads in GarageBand, long press on it and choose Share. Continue the steps to set your ringtone.",
            imageName: "usage_tutorial_step_2"
        )
    ]
    
    // MARK: - Methods
    public init() {}
}
