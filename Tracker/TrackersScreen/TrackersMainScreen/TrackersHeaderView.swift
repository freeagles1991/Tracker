//
//  HeaderView.swift
//  Tracker
//
//  Created by Дима on 09.08.2024.
//

import Foundation
import UIKit

final class TrackersHeaderView: UICollectionReusableView {
    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "SFProText-Bold", size: 19)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutIfNeeded()
        let availableWidth = frame.width
        
        //let fontSizeTitle: CGFloat = availableWidth > 167 ? 22 : 19
        //label.font = UIFont(name: "SFProText-Bold", size: fontSizeTitle)
    }
}

