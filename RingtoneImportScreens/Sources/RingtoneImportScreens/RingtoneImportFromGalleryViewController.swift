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
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        
        addChild(picker)
        view.addSubview(picker.view)
    }
}

// MARK: - PHPickerViewControllerDelegate
extension RingtoneImportFromGalleryViewController: PHPickerViewControllerDelegate {
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        guard !results.isEmpty else {
            dismiss(animated: true)
            return
        }
        
        print(results)
        dismiss(animated: true)
    }
}
