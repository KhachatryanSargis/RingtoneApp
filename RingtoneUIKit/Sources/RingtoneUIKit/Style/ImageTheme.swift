//
//  ImageTheme.swift
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
    public let pause = UIImage(systemName: "pause.circle.fill")!.withConfiguration(configuration)
    public let like = UIImage(systemName: "heart")!.withConfiguration(configuration)
    public let liked = UIImage(systemName: "heart.fill")!.withConfiguration(configuration)
    public let edit = UIImage(systemName: "scissors")!.withConfiguration(configuration)
    public let use = UIImage(systemName: "bell")!.withConfiguration(configuration)
    
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
    public let menu = UIImage(systemName: "ellipsis.circle")!.withConfiguration(configuration)
    public let select = UIImage(systemName: "checkmark.circle")!.withConfiguration(configuration)
    public let gallery = UIImage(systemName: "photo")!.withConfiguration(configuration)
    public let files = UIImage(systemName: "folder")!.withConfiguration(configuration)
    public let link = UIImage(systemName: "link")!.withConfiguration(configuration)
    public let usage = UIImage(systemName: "questionmark.circle")!.withConfiguration(configuration)
    
    // MARK: - RingtoneCreatedFailedHeader
    public let retry = UIImage(systemName: "arrow.circlepath")!.withConfiguration(configuration)
    public let clear = UIImage(systemName: "minus.circle")!.withConfiguration(configuration)
    
    // MARK: - RingtoneCreatedActionHeader
    public let delete = UIImage(systemName: "trash.circle")!.withConfiguration(configuration)
    
    // MARK: - RingtoneImportFromURLViewController
    public let download = UIImage(systemName: "arrow.down.circle")!.withConfiguration(configuration)
    public let cancel = UIImage(systemName: "xmark.circle")!.withConfiguration(configuration)
    
    // MARK: - RingtoneEditViewController
    public let zoomIn = UIImage(systemName: "plus.magnifyingglass")!.withConfiguration(configuration)
    public let zoomOut = UIImage(systemName: "minus.magnifyingglass")!.withConfiguration(configuration)
    public let reset = UIImage(systemName: "1.magnifyingglass")!.withConfiguration(configuration)
    
    // MARK: - RingtoneSlider
    public let fadeIn = UIImage(systemName: "arrowtriangle.backward.fill")!.withConfiguration(configuration)
    public let fadeOut = UIImage(systemName: "arrowtriangle.forward.fill")!.withConfiguration(configuration)
    
    // MARK: - RingtoneStepper
    public let plus = UIImage(systemName: "plus.circle")!.withConfiguration(configuration)
    public let minus = UIImage(systemName: "minus.circle")!.withConfiguration(configuration)
}
