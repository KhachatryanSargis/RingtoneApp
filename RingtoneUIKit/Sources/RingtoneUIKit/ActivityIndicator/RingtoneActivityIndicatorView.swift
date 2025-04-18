//
//  RingtoneActivityIndicatorView.swift
//  RingtoneUIKit
//
//  Created by Sargis Khachatryan on 18.04.25.
//

import UIKit

final class RingtoneActivityIndicatorView: NiblessView {
    // MARK: - Properties
    private let backgroundView: NiblessView = {
        let view = NiblessView()
        view.backgroundColor = .theme.shadowColor
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        view.alpha = 0.25
        return view
    }()
    
    private let activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .large)
        activityIndicatorView.color = .white
        return activityIndicatorView
    }()
    
    // MARK: - Methods
    override init() {
        super.init()
        constructHierarchy()
    }
    
    func startAnimating(_ message: String? = nil) {
        activityIndicatorView.startAnimating()
    }
    
    func stopAnimating() {
        activityIndicatorView.stopAnimating()
    }
}

// MARK: - Hierarchy
extension RingtoneActivityIndicatorView {
    private func constructHierarchy() {
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicatorView)
        NSLayoutConstraint.activate([
            leftAnchor.constraint(equalTo: activityIndicatorView.leftAnchor, constant: -16),
            rightAnchor.constraint(equalTo: activityIndicatorView.rightAnchor, constant: 16),
            topAnchor.constraint(equalTo: activityIndicatorView.topAnchor, constant: -16),
            bottomAnchor.constraint(equalTo: activityIndicatorView.bottomAnchor, constant: 16)
        ])
        
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(backgroundView, at: 0)
        NSLayoutConstraint.activate([
            backgroundView.leftAnchor.constraint(equalTo: leftAnchor),
            backgroundView.rightAnchor.constraint(equalTo: rightAnchor),
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
