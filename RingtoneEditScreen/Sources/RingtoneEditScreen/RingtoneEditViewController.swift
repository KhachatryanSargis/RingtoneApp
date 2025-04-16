//
//  File.swift
//  RingtoneEditScreen
//
//  Created by Sargis Khachatryan on 07.04.25.
//

import UIKit
import RingtoneUIKit
import RingtoneKit

public final class RingtoneEditViewController: NiblessViewController {
    // MARK: - Properties
    private let viewModel: RingtoneEditViewModel
    
    // MARK: - Methods
    public init(viewModel: RingtoneEditViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    public override func loadView() {
        view = RingtoneEditView(viewModel: viewModel)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureViewActions()
    }
}

// MARK: - View Actions
extension RingtoneEditViewController {
    private func configureViewActions() {
        guard let view = view as? RingtoneEditView else { return }
        
        view.onCancelButtonTapped = { [weak self] in
            guard let self = self else { return }
            
            guard let presentingViewController = self.presentingViewController
            else { return }
            
            presentingViewController.dismiss(animated: true)
        }
        
        view.onSaveButtonTapped = { [weak self] in
            guard let self = self else { return }
            
            guard let presentingViewController = self.presentingViewController
            else { return }
            
            presentingViewController.dismiss(animated: true)
        }
    }
}
