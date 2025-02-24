//
//  RingtoneNavigationController.swift
//  RingtoneUIKit
//
//  Created by Sargis Khachatryan on 24.02.25.
//

import UIKit

public final class RingtoneNavigationController: NiblessNavigationController {
    public init(rootViewController: UIViewController? = nil, prefersLargeTitles: Bool = true) {
        if let rootViewController = rootViewController {
            super.init(rootViewController: rootViewController)
        } else {
            super.init()
        }
        setNavigationBarAppearance()
        if prefersLargeTitles { setNavigationBarprefersLargeTitles() }
    }
}

// MARK: - Style
extension RingtoneNavigationController {
    private func setNavigationBarAppearance() {
        navigationBar.shadowImage = UIImage()
    }
    
    private func setNavigationBarprefersLargeTitles() {
        navigationBar.prefersLargeTitles = true
    }
}
