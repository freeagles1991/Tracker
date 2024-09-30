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
        colorView.layer.cornerRadius = 8
        colorView.layer.masksToBounds = true
        colorView.backgroundColor = .gray
        
        selectionRect.translatesAutoresizingMaskIntoConstraints = false
        selectionRect.backgroundColor = .white
        selectionRect.layer.cornerRadius = 8
        selectionRect.layer.masksToBounds = true
        selectionRect.layer.borderWidth = 3
        selectionRect.layer.borderColor = UIColor.white.cgColor
        
        contentView.addSubview(selectionRect)
        contentView.addSubview(colorView)
        
        NSLayoutConstraint.activate([
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.77),
            colorView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.77),
            
            selectionRect.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            selectionRect.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectionRect.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            selectionRect.widthAnchor.constraint(equalTo: contentView.widthAnchor)
        ])
    }
    
    private func updateSelectionAppearance() {
        if isSelected {
            selectionRect.layer.borderColor = color?.withAlphaComponent(0.3).cgColor
        } else {
            selectionRect.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    func configure(with color: UIColor) {
        self.color = color
        colorView.backgroundColor = color
        updateSelectionAppearance()
    }
}

