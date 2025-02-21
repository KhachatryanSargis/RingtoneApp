//
//  NiblessTabBarController.swift
//  ArorUIKit
//
//  Created by Sargis Khachatryan on 27.10.24.
//

import UIKit

open class NiblessTabBarController: UITabBarController {
    // MARK: - Methods
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(
        *,
         unavailable,
         message: "Loading this tab bar controller from a nib is unsupported."
    )
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(
        *,
         unavailable,
         message: "Loading this tab bar controller from a nib is unsupported."
    )
    required public init?(coder: NSCoder) {
        fatalError("Loading this tab bar controller from a nib is unsupported.")
    }
}
