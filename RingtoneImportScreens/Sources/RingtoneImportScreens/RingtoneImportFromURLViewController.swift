//
//  RingtoneImportFromURLViewController.swift
//  RingtoneImportScreens
//
//  Created by Sargis Khachatryan on 26.03.25.
//

import Foundation
import Combine
import RingtoneUIKit
import RingtoneKit

public final class RingtoneImportFromURLViewController: NiblessViewController {
    // MARK: - Properties
    private var cancellables = Set<AnyCancellable>()
    private let viewModelFactory: RingtoneImportViewModelFactory
    
    // MARK: - Methods
    public init(viewModelFactory: RingtoneImportViewModelFactory) {
        self.viewModelFactory = viewModelFactory
        super.init()
    }
    
    public override func loadView() {
        let viewModel = viewModelFactory.makeRingtoneImportViewModel()
        observeViewModelError(viewModel)
        view = RingtoneImportFromURLView(viewModel: viewModel)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationItem()
        disableSwipeDownDismiss()
    }
    
    private func disableSwipeDownDismiss() {
        isModalInPresentation = true
    }
}

// MARK: - Navigation Item
extension RingtoneImportFromURLViewController {
    private func configureNavigationItem() {
        navigationItem.rightBarButtonItem = .init(systemItem: .cancel, primaryAction: .init(handler: { [weak self] _ in
            guard let self = self else { return }
            
            let viewModel = viewModelFactory.makeRingtoneImportViewModel()
            viewModel.cancelCurrentDownloads()
            
            guard let presentingViewController = presentingViewController
            else { return }
            
            presentingViewController.dismiss(animated: true)
        }))
    }
}

// MARK: - Observe Download Result
extension RingtoneImportFromURLViewController {
    private func observeViewModelError(_ viewModel: RingtoneImportViewModel) {
        viewModel.downloadResultPublisher
            .sink { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .complete:
                    guard let presentingViewController = self.presentingViewController
                    else { return }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        presentingViewController.dismiss(animated: true)
                    }
                case .failed(let item):
                    (self.view as! RingtoneImportFromURLView).finish()
                    
                    self.showAlert(title: "Error", message: "\(item.error)")
                }
            }
            .store(in: &cancellables)
    }
}
