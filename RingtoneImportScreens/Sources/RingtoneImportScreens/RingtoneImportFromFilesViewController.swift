//
//  RingtoneImportFromFilesViewController.swift
//  RingtoneCreatedScreen
//
//  Created by Sargis Khachatryan on 27.02.25.
//

import UIKit
import UniformTypeIdentifiers
import RingtoneUIKit

public final class RingtoneImportFromFilesViewController: NiblessViewController {
    public override func viewDidLoad() {
        super.viewDidLoad()
        setBackgroundColor()
        addChildUIDocumentPickerViewController()
    }
}

// MARK: - Style
extension RingtoneImportFromFilesViewController {
    private func setBackgroundColor() {
        view.backgroundColor = .theme.background
    }
}

// MARK: - UIDocumentPickerViewController
extension RingtoneImportFromFilesViewController {
    private func addChildUIDocumentPickerViewController() {
        let supportedTypes: [UTType] = [
            .audio,
            .movie,
            .quickTimeMovie,
            .mp3,
            .mpeg,
            .appleProtectedMPEG4Video
        ]
        
        let documentPickerViewController = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
        
        documentPickerViewController.delegate = self
        documentPickerViewController.allowsMultipleSelection = false
        
        addChild(documentPickerViewController)
        view.addSubview(documentPickerViewController.view)
    }
}

// MARK: - UIDocumentPickerDelegate
extension RingtoneImportFromFilesViewController: UIDocumentPickerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        for url in urls {
            print("Selected file URL: \(url)")
        }
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        dismiss(animated: true)
    }
}
