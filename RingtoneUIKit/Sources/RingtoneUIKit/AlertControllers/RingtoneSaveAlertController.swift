//
//  RingtoneSaveAlertController.swift
//  RingtoneUIKit
//
//  Created by Sargis Khachatryan on 23.04.25.
//

import UIKit

extension UIAlertController {
    public static func saveAlertController(
        onCreateCopy: @escaping () -> Void,
        onReplaceOriginal: @escaping () -> Void
    ) -> UIAlertController {
        
        let alertController = UIAlertController(
            title: "How would you like to save this ringtone?",
            message: "You can replace the original or create a copy.",
            preferredStyle: .actionSheet
        )
        
        let createCopyAction = RingtoneAlertAction(
            title: "Save as a Copy",
            style: .default
        ) { _ in
            onCreateCopy()
        }
        
        let replaceOriginalAction = UIAlertAction(
            title: "Replace Original",
            style: .destructive
        ) { _ in
            onReplaceOriginal()
        }
        
        let cancelAction = RingtoneAlertAction(
            title: "Cancel",
            style: .cancel
        )
        
        alertController.addAction(createCopyAction)
        alertController.addAction(replaceOriginalAction)
        alertController.addAction(cancelAction)
        
        return alertController
    }
}
