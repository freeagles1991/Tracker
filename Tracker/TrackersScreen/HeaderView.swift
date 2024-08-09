//
//  HeaderView.swift
//  Tracker
//
//  Created by Дима on 09.08.2024.
//

import Foundation
import UIKit

class HeaderView: UICollectionReusableView {
    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "SF Pro", size: 19)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Инициализатор
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label.backgroundColor = .gray
        
        addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

