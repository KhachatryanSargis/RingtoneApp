//
//  RingtoneImportFromURLViewController.swift
//  RingtoneImportScreens
//
//  Created by Sargis Khachatryan on 26.03.25.
//

import RingtoneUIKit
import RingtoneKit

public final class RingtoneImportFromURLViewController: NiblessViewController {
    // MARK: - Properties
    private let viewModelFactory: RingtoneImportViewModelFactory
    
    // MARK: - Methods
    public init(viewModelFactory: RingtoneImportViewModelFactory) {
        self.viewModelFactory = viewModelFactory
        super.init()
    }
}
