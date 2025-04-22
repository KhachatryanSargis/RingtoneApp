//
//  File.swift
//  RingtoneEditScreen
//
//  Created by Sargis Khachatryan on 07.04.25.
//

import UIKit
import Combine
import RingtoneUIKit
import RingtoneKit

public final class RingtoneEditViewController: NiblessViewController {
    // MARK: - Properties
    private var cancellables: Set<AnyCancellable> = []
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
        observeViewModelLoading()
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
            
            viewModel.stopPlayback()
            
            presentingViewController.dismiss(animated: true)
        }
        
        view.onSaveButtonTapped = { [weak self] in
            guard let self = self else { return }
            
            guard let presentingViewController = self.presentingViewController
            else { return }
            
            viewModel.stopPlayback()
            
            presentingViewController.dismiss(animated: true)
        }
    }
}

// MARK: - View Model Loading
extension RingtoneEditViewController {
    private func observeViewModelLoading() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] isLoading in
                guard let self = self else { return }
                
                if isLoading {
                    self.startLoading()
                } else {
                    self.stopLoading()
                }
            }
            .store(in: &cancellables)
    }
}
