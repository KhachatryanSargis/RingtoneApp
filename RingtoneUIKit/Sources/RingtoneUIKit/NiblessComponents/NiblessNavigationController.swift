//
//  NiblessNavigationController.swift
//  ArorUIKit
//
//  Created by Sargis Khachatryan on 12.10.24.
//

import UIKit

open class NiblessNavigationController: UINavigationController {
    // MARK: - Methods
    public init(rootViewController: UIViewController? = nil, prefersLargeTitles: Bool = true) {
        if let rootViewController = rootViewController {
            super.init(rootViewController: rootViewController)
        } else {
            super.init()
        }
        if prefersLargeTitles { setNavigationBarprefersLargeTitles() }
    }
    
    @available(
        *,
         unavailable,
         message: "Loading this navigation controller from a nib is unsupported."
    )
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(
        *,
         unavailable,
         message: "Loading this navigation controller from a nib is unsupported."
    )
    required public init?(coder aDecoder: NSCoder) {
        fatalError("Loading this navigation controller from a nib is unsupported.")
    }
}

// MARK: - Style
extension NiblessNavigationController {
    private func setNavigationBarprefersLargeTitles() {
        navigationBar.prefersLargeTitles = true
    }
}
