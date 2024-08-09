//
//  TrackersCell.swift
//  Tracker
//
//  Created by Дима on 08.08.2024.
//

import Foundation
import UIKit

class TrackerCell: UICollectionViewCell {
    // Элементы ячейки
    private let emojiLabel = UILabel()
    private let titleLabel = UILabel()
    private let colorPanelView = UIView()
    private let durationLabel = UILabel()
    private let completeButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Настройка элементов ячейки
    private func setupViews() {
        ///Настраиваем блок с заголовком
        let titleBlockView = UIView()
        titleBlockView.translatesAutoresizingMaskIntoConstraints = false
        
        
        emojiLabel.font = UIFont(name: "SF Pro", size: 16)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = UIFont(name: "SF Pro", size: 12)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        colorPanelView.layer.cornerRadius = 16
        colorPanelView.translatesAutoresizingMaskIntoConstraints = false

        titleBlockView.addSubview(colorPanelView)
        titleBlockView.addSubview(emojiLabel)
        titleBlockView.addSubview(titleLabel)
        
        contentView.addSubview(titleBlockView)
        
        NSLayoutConstraint.activate([
            titleBlockView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleBlockView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleBlockView.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleBlockView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -58),
            
            colorPanelView.leadingAnchor.constraint(equalTo: titleBlockView.leadingAnchor),
            colorPanelView.trailingAnchor.constraint(equalTo: titleBlockView.trailingAnchor),
            colorPanelView.topAnchor.constraint(equalTo: titleBlockView.topAnchor),
            colorPanelView.bottomAnchor.constraint(equalTo: titleBlockView.bottomAnchor),

            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.topAnchor.constraint(equalTo: colorPanelView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: colorPanelView.leadingAnchor, constant: 12),

            titleLabel.leadingAnchor.constraint(equalTo: colorPanelView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: colorPanelView.trailingAnchor, constant: -12),
            titleLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 8)
        ])
        
        ///Настраиваем нижний блок с кнопкой
        let  bottomBlockView = UIView()
        bottomBlockView.translatesAutoresizingMaskIntoConstraints = false
        
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        completeButton.setImage(UIImage(named: "PlusButton")?.withRenderingMode(.alwaysTemplate), for: .normal)
        
        
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.font = UIFont(name: "SF Pro", size: 12)
        durationLabel.textColor = .black
        durationLabel.text = "1 день"
        
        
        bottomBlockView.addSubview(completeButton)
        bottomBlockView.addSubview(durationLabel)
        
        contentView.addSubview(bottomBlockView)
        
        NSLayoutConstraint.activate([
            bottomBlockView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomBlockView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomBlockView.topAnchor.constraint(equalTo: titleBlockView.bottomAnchor),
            bottomBlockView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            completeButton.heightAnchor.constraint(equalToConstant: 34),
            completeButton.widthAnchor.constraint(equalToConstant: 34),
            completeButton.trailingAnchor.constraint(equalTo: bottomBlockView.trailingAnchor, constant: -12),
            completeButton.topAnchor.constraint(equalTo: bottomBlockView.topAnchor, constant: 8),

            durationLabel.leadingAnchor.constraint(equalTo: bottomBlockView.leadingAnchor, constant: 12),
            durationLabel.topAnchor.constraint(equalTo: bottomBlockView.topAnchor, constant: 16)
        ])
    }

    // Метод для настройки ячейки
    func configure(with tracker: Tracker) {
        emojiLabel.text = tracker.emoji
        titleLabel.text = tracker.title

        // Преобразование цвета из строки в UIColor
        if let color = UIColor(hexString: tracker.color) {
            colorPanelView.backgroundColor = color
            completeButton.tintColor = color
        } else {
            colorPanelView.backgroundColor = .gray
            completeButton.tintColor = .gray
        }
    }
}

extension UIColor {
    // Метод для преобразования hex строки в UIColor
    convenience init?(hexString: String) {
        var hex = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        hex = hex.replacingOccurrences(of: "#", with: "")

        guard hex.count == 6 else { return nil }

        var rgbValue: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgbValue)

        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

