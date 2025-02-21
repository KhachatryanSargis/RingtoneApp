//
//  NiblessView.swift
//  ArorUIKit
//
//  Created by Sargis Khachatryan on 10.10.24.
//

import UIKit

open class NiblessView: UIView {
    // MARK: - Methods
    public init() {
        super.init(frame: .zero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @available(
        *,
         unavailable,
         message: "Loading this view from a nib is unsupported."
    )
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Loading this view from a nib is unsupported.")
    }
}
