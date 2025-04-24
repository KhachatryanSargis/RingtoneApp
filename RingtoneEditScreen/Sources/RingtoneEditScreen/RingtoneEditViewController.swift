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
        observeViewModelState()
    }
}

// MARK: - View Actions
extension RingtoneEditViewController {
    private func configureViewActions() {
        guard let view = view as? RingtoneEditView else { return }
        
        view.onCancelButtonTapped = { [weak self] in
            guard let self = self else { return }
            
            self.viewModel.cancel()
        }
        
        view.onSaveButtonTapped = { [weak self] in
            guard let self = self else { return }
            
            if self.viewModel.hasChanges {
                let alertController = UIAlertController.saveAlertController {
                    self.viewModel.save(mode: .saveAsCopy)
                } onReplaceOriginal: {
                    self.viewModel.save(mode: .replaceOriginal)
                }
                
                self.present(alertController, animated: true)
            } else {
                self.viewModel.cancel()
            }
        }
    }
}

// MARK: - View Model Loading
extension RingtoneEditViewController {
    private func observeViewModelState() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self = self else { return }
                
                switch state {
                case .isEditing:
                    self.stopLoading()
                case .isLoading:
                    self.startLoading()
                case .failed(let error):
                    self.stopLoading()
                    
                    self.showAlert(title: "Error", message: "\(error)")
                case .finished:
                    self.stopLoading()
                    
                    guard let presentingViewController = self.presentingViewController
                    else { return }
                    
                    presentingViewController.dismiss(animated: true)
                }
            }
            .store(in: &cancellables)
    }
}
