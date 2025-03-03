//
//  RingtoneImportFromGalleryViewController.swift
//  RingtoneCreatedScreen
//
//  Created by Sargis Khachatryan on 27.02.25.
//

import UIKit
import PhotosUI
import RingtoneUIKit

public final class RingtoneImportFromGalleryViewController: NiblessViewController {
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
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 0
        configuration.filter = .videos
        
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
        guard let presentingViewController = presentingViewController else { return }
        presentingViewController.dismiss(animated: true)
    }
}
