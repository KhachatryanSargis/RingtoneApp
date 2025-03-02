//
//  RingtoneDiscoverViewController.swift
//  RingtoneDiscoverScreen
//
//  Created by Sargis Khachatryan on 22.02.25.
//

import UIKit
import Combine
import RingtoneUIKit
import RingtoneKit

public final class RingtoneDiscoverViewController: NiblessViewController {
    // MARK: - Properties
    private var cancellables: Set<AnyCancellable> = []
    private let viewModelFactory: RingtoneDiscoverViewModelFactory
    
    // MARK: - Methods
    public init(viewModelFactory: RingtoneDiscoverViewModelFactory) {
        self.viewModelFactory = viewModelFactory
        super.init(enableKeyboardNotificationObservers: false)
    }
    
    public override func loadView() {
        let viewModel = viewModelFactory.makeRingtoneDiscoverViewModel()
        observeViewModelAction(viewMode: viewModel)
        view = RingtoneDiscoverView(viewModel: viewModel)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBarItem()
        configureNavigationItem()
    }
}

// MARK: - Tab Bar Item
extension RingtoneDiscoverViewController {
    private func configureTabBarItem() {
        guard let tabBarItem = tabBarItem else { return }
        tabBarItem.title = "Discover"
        tabBarItem.image = .theme.discover
    }
}

// MARK: - Navigation Item
extension RingtoneDiscoverViewController {
    private func configureNavigationItem() {
        navigationItem.title = String(
            localized: "Discover",
            comment: "The title of the ringtone discover screen."
        )
    }
}

// MARK: - View Model
extension RingtoneDiscoverViewController {
    private func observeViewModelAction(viewMode: RingtoneDiscoverViewModel) {
        viewMode.$action
            .compactMap { $0 }
            .sink { [weak self] action in
                guard let self = self else { return }
                
                switch action {
                case .export(let audio):
                    self.exportAudio(audio)
                case .edit(let audio):
                    self.editAudio(audio)
                }
            }
            .store(in: &cancellables)
    }
    
    private func exportAudio(_ audio: RingtoneAudio) {
        let activityViewController = UIActivityViewController(
            activityItems: [audio.url],
            applicationActivities: nil
        )
        
        if #available(iOS 16.4, *) {
            activityViewController.excludedActivityTypes = [
                .postToFacebook,
                .postToTwitter,
                .postToWeibo,
                .message,
                .mail,
                .print,
                .copyToPasteboard,
                .assignToContact,
                .saveToCameraRoll,
                .addToReadingList,
                .postToFlickr,
                .postToVimeo,
                .postToTencentWeibo,
                .airDrop,
                .openInIBooks,
                .markupAsPDF,
                .sharePlay,
                .collaborationInviteWithLink,
                .collaborationCopyLink,
                .addToHomeScreen
            ]
        } else {
            activityViewController.excludedActivityTypes = [
                .postToFacebook,
                .postToTwitter,
                .postToWeibo,
                .message,
                .mail,
                .print,
                .copyToPasteboard,
                .assignToContact,
                .saveToCameraRoll,
                .addToReadingList,
                .postToFlickr,
                .postToVimeo,
                .postToTencentWeibo,
                .airDrop,
                .openInIBooks,
                .markupAsPDF
            ]
        }
        
        present(activityViewController, animated: true, completion: nil)
        
        activityViewController.completionWithItemsHandler = { activity, completed, returnedItems, error in
            if completed {
                print("MP3 file successfully exported to GarageBand.")
            } else {
                if let error = error {
                    print("Error exporting MP3 file: \(error.localizedDescription)")
                } else {
                    print("Export canceled.")
                }
            }
        }
    }
    
    private func editAudio(_ audio: RingtoneAudio) {
        
    }
}
