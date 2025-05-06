//
//  RingtoneUsageTutorialViewController.swift
//  RingtoneTutorialScreens
//
//  Created by Sargis Khachatryan on 05.05.25.
//

import UIKit
import RingtoneUIKit
import RingtoneKit

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
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationItem()
    }
}

// MARK: - Navigation Item
extension RingtoneUsageTutorialViewController {
    private func configureNavigationItem() {
        setNavigationItemTitle()
        addCloseBarButtonItem()
    }
    
    private func setNavigationItemTitle() {
        navigationItem.title = String(
            localized: "How to use a ringtone?",
            comment: "The title of the ringtone usage tutorial screen."
        )
    }
    
    private func addCloseBarButtonItem() {
        let closeBarButtonItem = UIBarButtonItem(
            systemItem: .close,
            primaryAction: .init(
                handler: { [weak self] _ in
                    guard let self = self else { return }
                    
                    guard let presentingViewController = self.presentingViewController
                    else { return }
                    
                    presentingViewController.dismiss(animated: true)
                })
        )
        
        navigationItem.setRightBarButton(
            closeBarButtonItem,
            animated: false
        )
    }
}
