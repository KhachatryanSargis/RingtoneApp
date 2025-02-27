//
//  RingtoneCreatedEmptyView.swift
//  RingtoneCreatedScreen
//
//  Created by Sargis Khachatryan on 26.02.25.
//

import UIKit
import RingtoneUIKit

final class RingtoneCreatedEmptyCell: NiblessCollectionViewCell {
    // MARK: - Properties
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .theme.headline
        label.textColor = .theme.label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "You have not created any ringtones yet."
        return label
    }()
    
    // MARK: - Methods
    override init() {
        super.init()
    }
}

// MARK: - Style
extension RingtoneCreatedEmptyCell {
    private func setBackgroundColor() {
        backgroundView
    }
}
