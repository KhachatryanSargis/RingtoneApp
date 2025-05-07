//
//  RingtoneDeleteAlertController.swift
//  RingtoneUIKit
//
//  Created by Sargis Khachatryan on 17.03.25.
//

import UIKit

extension UIAlertController {
    public static func deleteAlertController(isSingle: Bool, _ onDelete: @escaping () -> Void) -> UIAlertController {
        let title = isSingle ?
        "Are you sure you want to delete this ringtone?" :
        "Are you sure you want to delete selected ringtones?"
        
        let alertController = UIAlertController(
            title: title,
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
