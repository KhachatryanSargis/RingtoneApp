//
//  RingtoneTabBarController.swift
//  RingtoneUIKit
//
//  Created by Sargis Khachatryan on 22.02.25.
//

import UIKit

public final class RingtoneTabBarController: NiblessTabBarController {
    public override init() {
        super.init()
        setTabBarAppearance()
    }
}

// MARK: - Style
extension RingtoneTabBarController {
    private func setTabBarAppearance() {
        let appearance = UITabBarAppearance()
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
}
