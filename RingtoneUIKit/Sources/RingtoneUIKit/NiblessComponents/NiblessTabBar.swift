//
//  NiblessTabBar.swift
//  RingtoneUIKit
//
//  Created by Sargis Khachatryan on 22.02.25.
//

import UIKit

open class NiblessTabBar: UITabBar {
    // MARK: - Methods
    public init() {
        super.init(frame: .zero)
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @available(
        *,
         unavailable,
         message: "Loading this tab bar from a nib is unsupported."
    )
    required public init?(coder: NSCoder) {
        fatalError("Loading this tab bar from a nib is unsupported.")
    }
}
