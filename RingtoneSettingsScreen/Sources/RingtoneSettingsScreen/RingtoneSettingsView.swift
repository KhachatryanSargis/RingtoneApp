//
//  RingtoneSettingsView.swift
//  RingtoneSettingsScreen
//
//  Created by Sargis Khachatryan on 09.05.25.
//

import RingtoneUIKit
import RingtoneKit

final class RingtoneSettingsView: NiblessView {
    // MARK: - Properties
    private let viewModel: RingtoneSettingsViewModel
    
    // MARK: - Methods
    init(viewModel: RingtoneSettingsViewModel) {
        self.viewModel = viewModel
        super.init()
    }
}
