//
//  File.swift
//  ChallengeUIKit
//
//  Created by Sargis Khachatryan on 10.02.25.
//

import UIKit

extension UIImage {
    @MainActor public static let theme = ImageTheme()
}

@MainActor
public struct ImageTheme {
    private static let symbolConfiguration = UIImage.SymbolConfiguration(scale: .large)
    
    public let challengeIncomplete = UIImage(systemName: "checkmark.circle")!
    public let challengeComplete = UIImage(systemName: "checkmark.circle.fill")!.withConfiguration(symbolConfiguration)
    public let addChallenge = UIImage(systemName: "plus.circle.fill")!.withConfiguration(symbolConfiguration)
    public let close = UIImage(systemName: "xmark.circle.fill")!
}
