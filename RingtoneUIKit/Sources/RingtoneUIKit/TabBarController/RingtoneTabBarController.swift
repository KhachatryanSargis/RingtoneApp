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
//        setValue(RingtoneTabBar(frame: tabBar.frame), forKey: "tabBar")
        tabBar.standardAppearance = UITabBarAppearance()
        tabBar.scrollEdgeAppearance = UITabBarAppearance()
    }
}
