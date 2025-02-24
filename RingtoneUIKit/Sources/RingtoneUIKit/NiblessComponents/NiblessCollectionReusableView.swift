//
//  NiblessCollectionReusableView.swift
//  RingtoneUIKit
//
//  Created by Sargis Khachatryan on 24.02.25.
//

import UIKit

open class NiblessCollectionReusableView: UICollectionReusableView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @available(
        *,
         unavailable,
         message: "Loading this reusable view from a nib is unsupported."
    )
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
