//
//  RingtoneCreatedHeader.swift
//  RingtoneCreatedScreen
//
//  Created by Sargis Khachatryan on 10.03.25.
//

import UIKit
import RingtoneUIKit

final class RingtoneCreatedLoadingHeader: NiblessCollectionReusableView {
    // MARK: - Properties
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .theme.headline
        label.textColor = .theme.label
        label.text = "Loading From iCloud"
        return label
    }()
    
    // MARK: - Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        constructHierarchy()
    }
}

// MARK: - Hierarchy
extension RingtoneCreatedLoadingHeader {
    private func constructHierarchy() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -8),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
}
