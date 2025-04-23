//
//  RingtoneDeleteAlertController.swift
//  RingtoneUIKit
//
//  Created by Sargis Khachatryan on 17.03.25.
//

import UIKit

extension UIAlertController {
    public static func deleteAlertController(_ onDelete: @escaping () -> Void) -> UIAlertController {
        let alertController = UIAlertController(
            title: "Are you sure you want to delete selected ringtones?",
            message: "You can't undo this action.",
            preferredStyle: .alert
        )
        
        let cancelAction = RingtoneAlertAction(
            title: "Cancel",
            style: .cancel
        )
        
        let deleteAction = UIAlertAction(
            title: "Delete",
            style: .destructive
        ) { _ in
            onDelete()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
        return alertController
    }
}
