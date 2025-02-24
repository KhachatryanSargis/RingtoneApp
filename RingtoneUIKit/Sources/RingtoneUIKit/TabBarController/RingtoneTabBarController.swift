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
    
    public override func addChild(_ childController: UIViewController) {
        super.addChild(childController)
        // TODO: Find a better way to preload child controller.
        if let navigationController = childController as? UINavigationController {
            _ = navigationController.topViewController?.view
        } else {
            _ = childController.view
        }
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
