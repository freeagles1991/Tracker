//
//  Constants.swift
//  Tracker
//
//  Created by Дима on 10.09.2024.
//

typealias Binding<T> = (T) -> Void

import Foundation

public class Constants {
    public static var onboardingScreenWasShown: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "onboardingScreenWasShown")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "onboardingScreenWasShown")
        }
    }
}
