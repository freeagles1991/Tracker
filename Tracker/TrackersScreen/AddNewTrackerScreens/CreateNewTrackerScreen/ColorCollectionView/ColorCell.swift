//
//  ColorCell.swift
//  Tracker
//
//  Created by Дима on 22.08.2024.
//

import Foundation
import UIKit

final class ColorCell: UICollectionViewCell {
    
    private var colorView = UIView()
    private var selectionRect = UIView()
    var color: UIColor?
    
    override var isSelected: Bool {
        didSet {
            updateSelectionAppearance()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        colorView.translatesAutoresizingMaskIntoConstraints = false
        colorView.layer.cornerRadius = 16
        colorView.layer.masksToBounds = true
        colorView.backgroundColor = .gray
        
        selectionRect.translatesAutoresizingMaskIntoConstraints = false
        selectionRect.backgroundColor = .white
        selectionRect.layer.cornerRadius = 16
        selectionRect.layer.masksToBounds = true
        
        contentView.addSubview(selectionRect)
        contentView.addSubview(colorView)
        
        NSLayoutConstraint.activate([
            colorView.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            colorView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            
            selectionRect.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            selectionRect.widthAnchor.constraint(equalTo: contentView.widthAnchor)
        ])
    }
    
    private func updateSelectionAppearance() {
        if isSelected {
            selectionRect.backgroundColor = color?.withAlphaComponent(0.3)
        } else {
            selectionRect.backgroundColor = .white
        }
    }
    
    func configure(with color: UIColor) {
        self.color = color
        colorView.backgroundColor = color
    }
}

