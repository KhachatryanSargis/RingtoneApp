//
//  WaveformSampleSelectionView.swift
//  RingtoneEditScreen
//
//  Created by Sargis Khachatryan on 08.04.25.
//

import UIKit
import RingtoneUIKit
import RingtoneKit

final class WaveformSampleSelectionView: NiblessView {
    private enum ActiveView {
        case handle
        case overlay
        case none
    }
    
    // MARK: - Properties
    @Published private(set) public var selectedRange: CountableRange<Int>!
    
    let waveFormView: WaveformView = {
        let waveformView = WaveformView()
        return waveformView
    }()
    
    private let overlayAndHandleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        return stackView
    }()
    
    private let overlayView: NiblessView = {
        let view = NiblessView()
        view.layer.cornerRadius = 8
        view.backgroundColor = .theme.shadowColor.withAlphaComponent(0.5)
        return view
    }()
    
    private let handleView: NiblessView = {
        let view = NiblessView()
        view.layer.cornerRadius = 8
        view.backgroundColor = .theme.shadowColor.withAlphaComponent(0.5)
        return view
    }()
    
    private var overlayViewLeftConstraint: NSLayoutConstraint? {
        didSet {
            oldValue?.isActive = false
            overlayViewLeftConstraint?.isActive = true
        }
    }
    
    private var handleViewRightConstraint: NSLayoutConstraint? {
        didSet {
            oldValue?.isActive = false
            handleViewRightConstraint?.isActive = true
        }
    }
    
    private var activeView: ActiveView = .none
    
    private var previousTouchLocation: CGPoint?
    
    // MARK: - Methods
    override init() {
        super.init()
        constructHierarchy()
    }
}

// MARK: - Hierarchy
extension WaveformSampleSelectionView {
    private func constructHierarchy() {
        waveFormView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(waveFormView)
        NSLayoutConstraint.activate([
            waveFormView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            waveFormView.rightAnchor.constraint(equalTo: rightAnchor, constant: -56),
            waveFormView.topAnchor.constraint(equalTo: topAnchor),
            waveFormView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        handleView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(handleView)
        
        let handleViewRightConstraint = handleView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16)
        self.handleViewRightConstraint = handleViewRightConstraint
        
        NSLayoutConstraint.activate([
            handleViewRightConstraint,
            handleView.widthAnchor.constraint(equalToConstant: 24),
            handleView.heightAnchor.constraint(equalTo: waveFormView.heightAnchor, multiplier: 0.8),
            handleView.centerYAnchor.constraint(equalTo: waveFormView.centerYAnchor)
        ])
        
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(overlayView)
        
        let overlayViewLeftConstraint = overlayView.leftAnchor.constraint(equalTo: waveFormView.leftAnchor)
        self.overlayViewLeftConstraint = overlayViewLeftConstraint
        
        NSLayoutConstraint.activate([
            overlayViewLeftConstraint,
            overlayView.rightAnchor.constraint(equalTo: handleView.leftAnchor, constant: -16),
            overlayView.heightAnchor.constraint(equalTo: waveFormView.heightAnchor),
            overlayView.centerYAnchor.constraint(equalTo: waveFormView.centerYAnchor)
        ])
    }
}

// MARK: - Touches Handling
extension WaveformSampleSelectionView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let touchLocation = touch.location(in: self)
        
        if previousTouchLocation == nil {
            previousTouchLocation = touchLocation
        }
        
        if handleView.frame.contains(touchLocation) {
            activeView = .handle
        } else if overlayView.frame.contains(touchLocation) {
            activeView = .overlay
        } else {
            activeView = .none
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        switch activeView {
        case .handle:
            let touchLocation = touch.location(in: self)
            let translation = touchLocation.x - previousTouchLocation!.x
            
            let newOverlayWidth = overlayView.bounds.width + translation
            
            if newOverlayWidth >= 0 && newOverlayWidth <= (waveFormView.bounds.width) {
                handleViewRightConstraint?.constant += translation
            }
            
            previousTouchLocation = touchLocation
        case .overlay:
            let touchLocation = touch.location(in: self)
            let translation = touchLocation.x - previousTouchLocation!.x
            
            let newHandleRightConstraintConstant = handleViewRightConstraint?.constant ?? 0 + translation
            
            if newHandleRightConstraintConstant >= -16 &&
                newHandleRightConstraintConstant <= (waveFormView.bounds.width - 16 - overlayView.bounds.width) {
                handleViewRightConstraint?.constant = newHandleRightConstraintConstant
                overlayView.frame.origin.x += translation
            }
            
            previousTouchLocation = touchLocation
        case .none:
            break
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeView = .none
        previousTouchLocation = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeView = .none
        previousTouchLocation = nil
    }
}
