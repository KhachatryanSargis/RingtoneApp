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
    private static let configuration = UIImage.SymbolConfiguration(scale: .large)
    
    // MARK: - RingtoneDiscoverCategoryCell
    public let icon = UIImage(systemName: "waveform")!.withConfiguration(configuration)
    
    // MARK: - RingtoneDiscoverAudioCell
    public let play = UIImage(systemName: "play.circle.fill")!.withConfiguration(configuration)
    public let pause = UIImage(systemName: "pause.circle")!.withConfiguration(configuration)
    public let like = UIImage(systemName: "heart")!.withConfiguration(configuration)
    public let liked = UIImage(systemName: "heart.fill")!.withConfiguration(configuration)
    public let edit = UIImage(systemName: "gearshape")!.withConfiguration(configuration)
    public let use = UIImage(systemName: "square.and.arrow.up")!.withConfiguration(configuration)
    
    // MARK: - RingtoneDiscoverViewContrller
    public let discover = UIImage(systemName: "waveform.badge.magnifyingglass")!.withConfiguration(configuration)
    
    // MARK: - RingtoneFavoritesViewContrller
    public let favorites = UIImage(systemName: "heart.square")!.withConfiguration(configuration)
    
    // MARK: - RingtoneCreatedViewContrller
    public let myRingtones = UIImage(systemName: "music.note.house")!.withConfiguration(configuration)
    
    // MARK: - RingtoneCreatedEmptyCell
    public let `import` = UIImage(systemName: "square.and.arrow.down")!.withConfiguration(configuration)
    
    // MARK: - RingtoneCreatedViewController
    public let import_fill = UIImage(systemName: "square.and.arrow.down.fill")!.withConfiguration(configuration)
    
    // MARK: - RingtoneCreatedFailedHeader
    public let retry = UIImage(systemName: "arrow.circlepath")!.withConfiguration(configuration)
    public let clear = UIImage(systemName: "minus.circle")!.withConfiguration(configuration)
}
