//
//  NiblessCollectionViewCell.swift
//  ChallengeUIKit
//
//  Created by Sargis Khachatryan on 09.02.25.
//

import UIKit

open class NiblessCollectionViewCell: UICollectionViewCell {
    // MARK: - Methods
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @available(
        *,
         unavailable,
         message: "Loading this cell from a nib is unsupported."
    )
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
