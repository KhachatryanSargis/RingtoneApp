//
//  RingtoneAlertAction.swift
//  RingtoneUIKit
//
//  Created by Sargis Khachatryan on 27.02.25.
//

import UIKit

public final class RingtoneAlertAction: UIAlertAction {
    public override init() {
        super.init()
        setTitleTextColor()
    }
}

// MARK: - Style
extension RingtoneAlertAction {
    private func setTitleTextColor() {
        setValue(UIColor.theme.accent, forKey: "titleTextColor")
    }
}
