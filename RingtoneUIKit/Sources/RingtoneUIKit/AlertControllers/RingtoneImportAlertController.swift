//
//  RingtoneImportAlertController.swift
//  RingtoneUIKit
//
//  Created by Sargis Khachatryan on 17.03.25.
//

import UIKit

extension UIAlertController {
    public static func importAlertController(
        fromGallery: @escaping () -> Void,
        fromFiles: @escaping () -> Void,
        fromURL: @escaping () -> Void
    ) -> UIAlertController {
        let alertController = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let importFromGalleryAction = RingtoneAlertAction(
            title: "Import from Gallery",
            style: .default
        ) { _ in
            fromGallery()
        }
        
        let importFromFilesAction = RingtoneAlertAction(
            title: "Import from Files",
            style: .default
        ) { _ in
            fromFiles()
        }
        
        let importFromURLAction = RingtoneAlertAction(
            title: "Download From a Link",
            style: .default
        ) { _ in
            fromURL()
        }
        
        let cancelAction = RingtoneAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil
        )
        
        alertController.addAction(importFromGalleryAction)
        alertController.addAction(importFromFilesAction)
        alertController.addAction(importFromURLAction)
        alertController.addAction(cancelAction)
        
        return alertController
    }
}
