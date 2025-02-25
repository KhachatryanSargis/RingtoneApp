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
    
    public let play = UIImage(systemName: "play.circle.fill")!.withConfiguration(symbolConfiguration)
    public let puase = UIImage(systemName: "pause.circle")!.withConfiguration(symbolConfiguration)
    public let edit = UIImage(systemName: "gearshape")!.withConfiguration(symbolConfiguration)
    public let unlike = UIImage(systemName: "heart.slash.circle.fill")!.withConfiguration(symbolConfiguration)
    public let like = UIImage(systemName: "heart.circle.fill")!.withConfiguration(symbolConfiguration)
}
