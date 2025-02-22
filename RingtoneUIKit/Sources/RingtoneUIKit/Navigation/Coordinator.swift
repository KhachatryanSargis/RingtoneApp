//
//  File.swift
//  ChallengeiOS
//
//  Created by Sargis Khachatryan on 07.02.25.
//

import UIKit
import Combine

@MainActor
public protocol Coordinator: Presentable {
    // MARK: - Properties
    var children: [AnyCancellable: Coordinator] { get }
    var statePublisher: CurrentValueSubject<CoordinatorState, Never> { get }
    
    // MARK: - Methods
    func start()
    func addChild(
        _ coordinator: Coordinator,
        modalPresentationStyle: UIModalPresentationStyle,
        completion: (() -> Void)?
    )
}
