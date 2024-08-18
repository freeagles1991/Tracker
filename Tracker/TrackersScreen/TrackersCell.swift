//
//  TrackersCell.swift
//  Tracker
//
//  Created by Дима on 08.08.2024.
//

import Foundation
import UIKit

class TrackerCell: UICollectionViewCell {
    weak var trackersVC: TrackersViewController?
    private var tracker: Tracker?
    
    private let emojiLabel = UILabel()
    private let titleLabel = UILabel()
    private let colorPanelView = UIView()
    private var durationCountInt: Int = 0
    private var durationLabel = UILabel()
    private let completeButton = UIButton()
    private var isTrackerComplete = false
    private var cellColor =  UIColor()
    
    private var selectedDate: Date?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        let titleBlockView = UIView()
        titleBlockView.translatesAutoresizingMaskIntoConstraints = false
        
        
        emojiLabel.font = UIFont.systemFont(ofSize: 16)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .left
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 2

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
            titleLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: colorPanelView.bottomAnchor, constant: -12)
        ])
        
        let  bottomBlockView = UIView()
        bottomBlockView.translatesAutoresizingMaskIntoConstraints = false
        
        // Настраиваем кнопку
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        completeButton.backgroundColor = .systemBlue // Начальный цвет фона
        completeButton.tintColor = .white // Цвет изображения
        
        // Устанавливаем системное изображение "плюс" из SF Symbols
        let plusImage = UIImage(systemName: "plus") // Системное изображение "плюс"
        completeButton.setImage(plusImage, for: .normal)
        completeButton.tintColor = .white // Цвет изображения "плюс"
        
        // Настраиваем круглую форму кнопки
        completeButton.layer.cornerRadius = 17
        completeButton.clipsToBounds = true
        
        completeButton.addTarget(self, action: #selector(completeButtonTapped(_:)), for: .touchUpInside)
        
        
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.font = UIFont.systemFont(ofSize: 12)
        durationLabel.textColor = .black
        // Убедитесь, что label использует Dynamic Type
        durationLabel.adjustsFontForContentSizeCategory = true
        durationLabel.numberOfLines = 0
        
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
    
    @objc private func completeButtonTapped(_ sender: UIButton){
        self.isTrackerComplete = !isTrackerComplete
        guard let selectedDate = trackersVC?.getDateFromUIDatePicker() else { return }
        let currentDate = Date()
        if selectedDate > currentDate {
            print("Выбрана дата позднее текущей")
        } else {
            if isTrackerComplete{
                encreaseDurationLabel()
            } else {
                decreaseDurationLabel()
            }
            updateUI(with: cellColor)
        }
    }
    
    private func encreaseDurationLabel(){
        durationCountInt += 1
        durationLabel.text = "\(durationCountInt) \(declensionForDay(durationCountInt))"
        guard let tracker = self.tracker, let selectedDate = selectedDate else { return }
        trackersVC?.setTrackerComplete(for: tracker, on: selectedDate)
    }
    
    private func decreaseDurationLabel(){
        durationCountInt -= 1
        durationLabel.text = "\(durationCountInt) \(declensionForDay(durationCountInt))"
        guard let tracker = self.tracker, let selectedDate = selectedDate else { return }
        trackersVC?.setTrackerIncomplete(for: tracker, on: selectedDate)
    }
    
    func updateUI(with color: UIColor) {
        colorPanelView.backgroundColor = color
        if isTrackerComplete {
            completeButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            completeButton.backgroundColor = color.withAlphaComponent(0.5)
        } else {
            completeButton.setImage(UIImage(systemName: "plus"), for: .normal)
            completeButton.backgroundColor = color.withAlphaComponent(1)
        }
    }
    
    func configure(with tracker: Tracker, on date: Date) {
        self.tracker = tracker
        emojiLabel.text = tracker.emoji
        titleLabel.text = tracker.title
        selectedDate = date
        cellColor = UIColor(hexString: tracker.color) ?? .gray
        self.isTrackerComplete = trackersVC?.isTrackerCompleted(tracker, on: date) ?? false
        updateUI(with: cellColor)
        self.durationCountInt = trackersVC?.numberOfRecords(for: tracker) ?? 0
        durationLabel.text = "\(durationCountInt) \(declensionForDay(durationCountInt))"
    }
    
    private func declensionForDay(_ count: Int) -> String {
        let lastDigit = count % 10
        let lastTwoDigits = count % 100

        if lastTwoDigits >= 11 && lastTwoDigits <= 19 {
            return "дней"
        }
        
        switch lastDigit {
        case 1:
            return "день"
        case 2, 3, 4:
            return "дня"
        default:
            return "дней"
        }
    }
}


