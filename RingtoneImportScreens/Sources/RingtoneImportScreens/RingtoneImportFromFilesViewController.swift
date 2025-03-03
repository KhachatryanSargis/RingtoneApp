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
        
        documentPickerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(documentPickerViewController.view)
        NSLayoutConstraint.activate([
            documentPickerViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            documentPickerViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            documentPickerViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            documentPickerViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        documentPickerViewController.didMove(toParent: self)
    }
}

// MARK: - UIDocumentPickerDelegate
extension RingtoneImportFromFilesViewController: UIDocumentPickerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let presentingViewController = presentingViewController else { return }
        presentingViewController.dismiss(animated: true)
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        guard let presentingViewController = presentingViewController else { return }
        presentingViewController.dismiss(animated: true)
    }
}
