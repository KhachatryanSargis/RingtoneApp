//
//  RingtoneCreatedView.swift
//  RingtoneCreatedScreen
//
//  Created by Sargis Khachatryan on 24.02.25.
//

import UIKit
import RingtoneUIKit
import RingtoneKit

final class RingtoneCreatedView: NiblessView {
    // MARK: - Properties
    private let viewModel: RingtoneCreatedViewModel
    
    // MARK: - Methods
    init(viewModel: RingtoneCreatedViewModel) {
        self.viewModel = viewModel
        super.init()
    }
}
