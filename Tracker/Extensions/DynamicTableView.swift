//
//  DynamicTableView.swift
//  Tracker
//
//  Created by Дима on 05.09.2024.
//

import Foundation
import UIKit

class DynamicTableView: UITableView {

    override public func layoutSubviews() {
        super.layoutSubviews()
        if bounds.size != intrinsicContentSize {
            invalidateIntrinsicContentSize()
        }
    }
    
    override public var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return contentSize
    }

}
