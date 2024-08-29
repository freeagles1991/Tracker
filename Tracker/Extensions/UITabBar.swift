//
//  UITabBar.swift
//  Tracker
//
//  Created by Дима on 17.08.2024.
//

import Foundation
import UIKit

extension UITabBar {
    func addTopBorder(with color: UIColor, andHeight borderHeight: CGFloat) {
        let borderLayer = CALayer()
        borderLayer.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: borderHeight)
        borderLayer.backgroundColor = color.cgColor
        self.layer.addSublayer(borderLayer)
    }
}
