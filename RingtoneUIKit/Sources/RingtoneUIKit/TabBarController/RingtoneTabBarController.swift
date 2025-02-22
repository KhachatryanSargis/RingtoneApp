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
        setRingtoneTabBar()
    }
}

// MARK: - Style
extension RingtoneTabBarController {
    private func setRingtoneTabBar() {
        setValue(RingtoneTabBar(frame: tabBar.frame), forKey: "tabBar")
    }
}
