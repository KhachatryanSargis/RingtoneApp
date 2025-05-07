//
//  RingtoneWarningAlertController.swift
//  RingtoneUIKit
//
//  Created by Sargis Khachatryan on 06.05.25.
//

import UIKit

extension UIAlertController {
    public static func warningAlertController(
        onEdit: @escaping () -> Void,
        onContinue: @escaping () -> Void
    ) -> UIAlertController {
        
        let alertController = UIAlertController(
            title: "Your ringtone length needs to be adjusted.",
            message: "Your ringtnone needs to be 30 seconds or less and will be automatically shortened by GarageBand.",
            preferredStyle: .actionSheet
        )
        
        let editAction = RingtoneAlertAction(
            title: "Adjust",
            style: .default
        ) { _ in
            onEdit()
        }
        
        let continueAction = RingtoneAlertAction(
            title: "Continue",
            style: .default
        ) { _ in
            onContinue()
        }
        
        let cancelAction = RingtoneAlertAction(
            title: "Cancel",
            style: .cancel
        )
        
        alertController.addAction(editAction)
        alertController.addAction(continueAction)
        alertController.addAction(cancelAction)
        
        return alertController
    }
}
