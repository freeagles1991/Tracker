//
//  TrackersCell.swift
//  Tracker
//
//  Created by Дима on 08.08.2024.
//

import Foundation
import UIKit

import UIKit

final class TrackerCell: UICollectionViewCell {
    weak var trackersVC: TrackersViewController?
    private let trackerRecordStore = TrackerRecordStore.shared
    private var tracker: Tracker?
    
    private let emojiLabel = UILabel()
    private let emojiBackground = UIView()
    private let titleLabel = UILabel()
    private let colorPanelView = UIView()
    private var durationCountInt: Int = 0
    private var durationLabel = UILabel()
    private let completeButton = UIButton()
    private var isTrackerComplete = false
    private var cellColor = UIColor()
    
    private var selectedDate: Date?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        let titleBlockView = UIView()
        titleBlockView.translatesAutoresizingMaskIntoConstraints = false
        
        emojiLabel.font = UIFont(name: "SFProText-Medium", size: 16)
        emojiLabel.textAlignment = .center
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        emojiBackground.translatesAutoresizingMaskIntoConstraints = false
        emojiBackground.backgroundColor = UIColor(named: "white")?.withAlphaComponent(0.3)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont(name: "SFProText-Medium", size: 12)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .left
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 2

        colorPanelView.layer.cornerRadius = 16
        colorPanelView.translatesAutoresizingMaskIntoConstraints = false
        
        emojiBackground.addSubview(emojiLabel)
        titleBlockView.addSubview(colorPanelView)
        titleBlockView.addSubview(emojiBackground)
        titleBlockView.addSubview(titleLabel)
        
        contentView.addSubview(titleBlockView)
        
        NSLayoutConstraint.activate([
            titleBlockView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleBlockView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleBlockView.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleBlockView.heightAnchor.constraint(equalTo: titleBlockView.widthAnchor, multiplier: 0.54),
            
            colorPanelView.leadingAnchor.constraint(equalTo: titleBlockView.leadingAnchor),
            colorPanelView.trailingAnchor.constraint(equalTo: titleBlockView.trailingAnchor),
            colorPanelView.topAnchor.constraint(equalTo: titleBlockView.topAnchor),
            colorPanelView.bottomAnchor.constraint(equalTo: titleBlockView.bottomAnchor),
            
            emojiBackground.leadingAnchor.constraint(equalTo: colorPanelView.leadingAnchor, constant: 12),
            emojiBackground.topAnchor.constraint(equalTo: colorPanelView.topAnchor, constant: 12),
            emojiBackground.heightAnchor.constraint(equalTo: colorPanelView.heightAnchor, multiplier: 0.27),
            emojiBackground.widthAnchor.constraint(equalTo: emojiBackground.heightAnchor, multiplier: 1.0),

            emojiLabel.heightAnchor.constraint(equalTo: emojiBackground.heightAnchor),
            emojiLabel.widthAnchor.constraint(equalTo: emojiBackground.widthAnchor),
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackground.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackground.centerYAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: colorPanelView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: colorPanelView.trailingAnchor, constant: -12),
            titleLabel.topAnchor.constraint(equalTo: colorPanelView.topAnchor, constant: 44),
            titleLabel.bottomAnchor.constraint(equalTo: colorPanelView.bottomAnchor, constant: -12)
        ])
        
        let bottomBlockView = UIView()
        bottomBlockView.translatesAutoresizingMaskIntoConstraints = false
        
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        completeButton.backgroundColor = .systemBlue
        completeButton.tintColor = .white
        completeButton.layer.cornerRadius = 17
        completeButton.clipsToBounds = true
        completeButton.setImage(UIImage(systemName: "plus"), for: .normal)
        completeButton.addTarget(self, action: #selector(completeButtonTapped(_:)), for: .touchUpInside)
        
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.font = UIFont(name: "SFProText-Medium", size: 12)
        durationLabel.textColor = .black
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
            
            completeButton.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.24),
            completeButton.widthAnchor.constraint(equalTo: completeButton.heightAnchor, multiplier: 1.0),
            completeButton.trailingAnchor.constraint(equalTo: bottomBlockView.trailingAnchor, constant: -12),
            completeButton.bottomAnchor.constraint(equalTo: bottomBlockView.bottomAnchor, constant: -16),

            durationLabel.leadingAnchor.constraint(equalTo: bottomBlockView.leadingAnchor, constant: 12),
            durationLabel.topAnchor.constraint(equalTo: bottomBlockView.topAnchor, constant: 16),
            durationLabel.bottomAnchor.constraint(equalTo: bottomBlockView.bottomAnchor, constant: -24),
            durationLabel.trailingAnchor.constraint(equalTo: bottomBlockView.trailingAnchor, constant: -54)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.layoutIfNeeded()
        let availableWidth = contentView.frame.width
        
        completeButton.layer.cornerRadius = completeButton.bounds.height / 2
        completeButton.layer.masksToBounds = true
        
        emojiBackground.layer.cornerRadius = emojiBackground.bounds.height / 2
        completeButton.layer.masksToBounds = true
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
    
    func getCellColorRectView() -> UIView {
        return colorPanelView
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
        self.isTrackerComplete = isTrackerCompleted(tracker, on: date)
        updateUI(with: cellColor)
        self.durationCountInt = numberOfRecords(for: tracker)
        durationLabel.text = String.localizedStringWithFormat(
            NSLocalizedString("daysCount", comment: "Количество дней"), durationCountInt)
    }
    
    func getTracker() -> Tracker? {
        guard let tracker else { return nil }
        return tracker
    }
    
    private func isTrackerCompleted(_ tracker: Tracker, on date: Date) -> Bool {
        let records = trackerRecordStore.fetchTrackerRecords(byID: tracker.id, on: date)
        return !records.isEmpty
    }
    
    private func numberOfRecords(for tracker: Tracker) -> Int {
        let records = trackerRecordStore.fetchTrackerRecords(byID: tracker.id)
        return records.count
        
    }
    
    private func encreaseDurationLabel() {
        durationCountInt += 1
        durationLabel.text = String.localizedStringWithFormat(
            NSLocalizedString("daysCount", comment: "Количество дней"), durationCountInt
        )
        guard let tracker = self.tracker, let selectedDate = selectedDate else { return }
        trackersVC?.setTrackerComplete(for: tracker, on: selectedDate)
    }
    
    private func decreaseDurationLabel() {
        durationCountInt -= 1
        durationLabel.text = String.localizedStringWithFormat(
            NSLocalizedString("daysCount", comment: "Количество дней"), durationCountInt)
        guard let tracker = self.tracker, let selectedDate = selectedDate else { return }
        trackersVC?.setTrackerIncomplete(for: tracker, on: selectedDate)
    }
}



