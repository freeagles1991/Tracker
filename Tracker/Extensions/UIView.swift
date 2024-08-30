//
//  UIView.swift
//  Tracker
//
//  Created by Дима on 18.08.2024.
//

import Foundation
import UIKit

extension UIView {

    func addTapGestureToHideKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        addGestureRecognizer(tapGesture)
    }

    var topSuperview: UIView? {
        var view = superview
        while let currentView = view, let superview = currentView.superview {
            view = superview
        }
        return view
    }

    @objc func dismissKeyboard() {
        topSuperview?.endEditing(true)
    }
}

