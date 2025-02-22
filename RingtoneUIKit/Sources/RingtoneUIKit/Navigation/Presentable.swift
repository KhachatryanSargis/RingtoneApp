//
//  File.swift
//  RingtoneUIKit
//
//  Created by Sargis Khachatryan on 22.02.25.
//

import UIKit

@MainActor
public protocol Presentable {
    func toViewController() -> UIViewController
}

// MARK: - NiblessViewController
extension NiblessViewController: Presentable {
    public func toViewController() -> UIViewController { return self }
}

// MARK: - NiblessNavigationController
extension NiblessNavigationController: Presentable {
    public func toViewController() -> UIViewController { return self }
}

// MARK: - NiblessTabBarController
extension NiblessTabBarController: Presentable {
    public func toViewController() -> UIViewController { return self }
}
