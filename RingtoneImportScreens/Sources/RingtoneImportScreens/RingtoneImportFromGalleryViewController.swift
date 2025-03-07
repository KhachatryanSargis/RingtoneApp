//
//  RingtoneImportFromGalleryViewController.swift
//  RingtoneCreatedScreen
//
//  Created by Sargis Khachatryan on 27.02.25.
//

import PhotosUI
import RingtoneUIKit
import RingtoneKit

public final class RingtoneImportFromGalleryViewController: NiblessViewController {
    // MARK: - Properties
    private let viewModelFactory: RingtoneImportViewModelFactory
    
    // MARK: - Methods
    public init(viewModelFactory: RingtoneImportViewModelFactory) {
        self.viewModelFactory = viewModelFactory
        super.init()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setBackgroundColor()
        addChildPHPickerViewController()
    }
}

// MARK: - Style
extension RingtoneImportFromGalleryViewController {
    private func setBackgroundColor() {
        view.backgroundColor = .theme.background
    }
}

// MARK: - PHPickerViewController
extension RingtoneImportFromGalleryViewController {
    private func addChildPHPickerViewController() {
        let photoLibrary = PHPhotoLibrary.shared()
        var configuration = PHPickerConfiguration(photoLibrary: photoLibrary)
        configuration.selectionLimit = 0
        configuration.filter = .videos
//        configuration.preferredAssetRepresentationMode = .current
        
        let pickerViewController = PHPickerViewController(configuration: configuration)
        pickerViewController.delegate = self
        
        addChild(pickerViewController)
        
        pickerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pickerViewController.view)
        NSLayoutConstraint.activate([
            pickerViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pickerViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pickerViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pickerViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        pickerViewController.didMove(toParent: self)
    }
}

// MARK: - PHPickerViewControllerDelegate
extension RingtoneImportFromGalleryViewController: PHPickerViewControllerDelegate {
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        guard !results.isEmpty
        else {
            guard let presentingViewController = presentingViewController
            else { return }
            
            presentingViewController.dismiss(animated: true)
            
            return
        }
        
        let itemProviders = results.map { $0.itemProvider }
        
        let viewModel = viewModelFactory.makeRingtoneImportViewModel()
        viewModel.createRingtoneItemsFromItemProviders(itemProviders)
        
        guard let presentingViewController = presentingViewController
        else { return }
        
        presentingViewController.dismiss(animated: true)
    }
}
