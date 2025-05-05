//
//  RingtoneUsageTutorialViewController.swift
//  RingtoneTutorialScreens
//
//  Created by Sargis Khachatryan on 05.05.25.
//

import RingtoneKit
import RingtoneUIKit

public final class RingtoneUsageTutorialViewController: NiblessViewController {
    // MARK: - Properties
    private let viewModelFactory: RingtoneUsageTutorialViewModelFactory
    
    // MARK: - Methods
    public init(viewModelFactory: RingtoneUsageTutorialViewModelFactory) {
        self.viewModelFactory = viewModelFactory
        super.init()
    }
    
    public override func loadView() {
        let viewModel = viewModelFactory.createRingtoneUsageTutorialViewModelFactory()
        view = RingtoneUsageTutorialView(viewModel: viewModel)
    }
}
