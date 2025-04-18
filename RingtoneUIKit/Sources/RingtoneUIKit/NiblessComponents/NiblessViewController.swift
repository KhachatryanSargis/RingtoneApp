//
//  NiblessViewController.swift
//  ArorUIKit
//
//  Created by Sargis Khachatryan on 03.10.24.
//

import UIKit

open class NiblessViewController: UIViewController {
    // MARK: - Properties
    private final let activityIndicatorView: RingtoneActivityIndicatorView = {
        let activityIndicatorView = RingtoneActivityIndicatorView()
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicatorView
    }()
    
    // MARK: - Methods
    public init(enableKeyboardNotificationObservers: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        if enableKeyboardNotificationObservers { addKeyboardNotificationObservers() }
    }
    
    @available(
        *,
         unavailable,
         message: "Loading this view controller from a nib is unsupported."
    )
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    @available(
        *,
         unavailable,
         message: "Loading this view controller from a nib is unsupported."
    )
    public required init?(coder: NSCoder) {
        fatalError("Loading this view controller from a nib is unsupported.")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    open func keyboardFrameChanged(_ frame: CGRect) {}
}

// MARK: - Keyboard
extension NiblessViewController {
    private func addKeyboardNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
                as? CGRect else { return }
        keyboardFrameChanged(keyboardFrame)
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
                as? CGRect else { return }
        keyboardFrameChanged(keyboardFrame)
    }
}

// MARK: - Loader
extension NiblessViewController {
    public final func startLoading() {
        view.addSubview(activityIndicatorView)
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        activityIndicatorView.startAnimating()
    }
    
    public final func stopLoading() {
        activityIndicatorView.stopAnimating()
        activityIndicatorView.removeFromSuperview()
    }
}

// MARK: - Show Alert
extension NiblessViewController {
    public final func showAlert(title: String, message: String) {
        let alertViewContrller = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction.init(title: "Ok", style: .cancel)
        
        alertViewContrller.addAction(okAction)
        
        present(alertViewContrller, animated: true)
    }
}
