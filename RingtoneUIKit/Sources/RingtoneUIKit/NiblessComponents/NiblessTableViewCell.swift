//
//  NiblessTableViewCell.swift
//  RingtoneUIKit
//
//  Created by Sargis Khachatryan on 10.05.25.
//

import UIKit

open class NiblessTableViewCell: UITableViewCell {
    // MARK: - Methods
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
