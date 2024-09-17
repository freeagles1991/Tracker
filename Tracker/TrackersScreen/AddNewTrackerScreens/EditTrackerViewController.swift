//
//  EditTrackerViewController.swift
//  Tracker
//
//  Created by Дима on 16.09.2024.
//

import Foundation
import UIKit

final class EditTrackerViewController: CreateNewTrackerViewController {
    private let screenTitleString: String = NSLocalizedString("EditTracker_screenTitleString", comment: "Редактирование привычки")
    private let saveButtonString: String = NSLocalizedString("EditTracker_saveButtonString", comment: "Сохранить")
    
    private var daysCounterLabel: UILabel = {
        let label = UILabel()
        // Форматирование
        return label
    }()
    
    private var daysCounterString: String?
    private let tracker: Tracker
    private let trackerStore = TrackerStore.shared
    
    init(tracker: Tracker) {
        self.tracker = tracker
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Устанавливаем заголовок и текст кнопки
        super.setScreenTitle(screenTitleString)
        super.setCreateButtonTitle(saveButtonString)
        
        // Получаем и отображаем количество дней
        getDaysCounterString()
        setupDaysCounter()
        
        // Заполняем начальные значения для редактирования
        populateFieldsWithTrackerData()
    }
    
    private func getDaysCounterString() {
        guard let trackerEntity = trackerStore.fetchTrackerEntity(tracker.id),
              let records = trackerEntity.records else { return }
        daysCounterString = String.localizedStringWithFormat(
            NSLocalizedString("daysCount", comment: "Количество дней"), records.count
        )
    }
    
    private func setupDaysCounter() {
        daysCounterLabel.text = daysCounterString
        view.addSubview(daysCounterLabel)
        // Верстка и позиционирование счетчика дней
        daysCounterLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            daysCounterLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            daysCounterLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func populateFieldsWithTrackerData() {
        super.populateFieldsWithTrackerData(tracker)
    }
}

