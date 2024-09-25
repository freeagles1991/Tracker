//
//  StatisticsStore.swift
//  Tracker
//
//  Created by Дима on 25.09.2024.
//

import Foundation
import CoreData
import UIKit

final class StatisticsStore {
    var fetchedResultsController: NSFetchedResultsController<TrackerEntity>?
    private let trackerStore = TrackerStore.shared
    
    private var appDelegate: AppDelegate {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("UIApplication.shared.delegate is not of type AppDelegate")
        }
        return delegate
    }
    
    private var context: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
    }
    
    //MARK: Настраиваем FRC
    func setupFetchedResultsController(_ predicate: NSPredicate, with trackerTitlePredicate: NSPredicate? = nil) {
        let fetchRequest: NSFetchRequest<TrackerEntity> = TrackerEntity.fetchRequest()
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
        ]

        fetchRequest.predicate = predicate
    
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "pinnedOrCategory",
            cacheName: nil
        )
        
        guard let fetchedResultsController else { return }
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Failed to fetch data: \(error)")
        }
    }
    
    //MARK: Завершенные трекеры
    public func fetchAllRecordsCount() -> Int {
        let allRecordsPredicate = NSPredicate(format: "records.@count > 0")
        
        self.setupFetchedResultsController(allRecordsPredicate)
        
        guard let fetchedObjects = fetchedResultsController?.fetchedObjects else {
            print("No fetched objects found")
            return 0
        }
        
        print("Fetched \(fetchedObjects.count) tracker entities with records")
        
        var totalRecordsCount = 0
        for trackerEntity in fetchedObjects {
            if let records = trackerEntity.records?.count {
                totalRecordsCount += records
            } else {
                print("No records found for tracker entity: \(trackerEntity)")
            }
        }
        
        print("Total records count: \(totalRecordsCount)")
        return totalRecordsCount
    }
    
    //MARK: Идеальные дни
    public func fetchPerfectDaysCount(from earliestDate: Date) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date()) // Начало текущего дня
        
        print("=== Старт расчета идеальных дней ===")
        print("Рассматриваем даты от: \(earliestDate) до: \(today)")
        
        // 1. Создаем массив дат в диапазоне от earliestDate до сегодняшнего дня
        var dates: [Date] = []
        var currentDate = calendar.startOfDay(for: earliestDate)
        
        while currentDate <= today {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        print("Создано \(dates.count) дат для проверки.")
        
        // 2. Фильтруем даты, на которые запланированы трекеры
        let scheduledDates = dates.filter { date in
            guard let selectedWeekday = Weekday.fromDate(date) else { return false }
            let predicate = NSPredicate(format: "schedule CONTAINS[cd] %@", selectedWeekday.rawValue)
            self.setupFetchedResultsController(predicate)
            
            let hasScheduledTrackers = fetchedResultsController?.fetchedObjects?.isEmpty == false
            print("Дата: \(date), Запланированные трекеры: \(hasScheduledTrackers ? "Есть" : "Нет")")
            return hasScheduledTrackers
        }
        
        print("Найдено \(scheduledDates.count) дат с запланированными трекерами.")
        
        // 3. Проверяем, является ли день "идеальным" (нет незавершенных трекеров)
        var perfectDays = scheduledDates.filter { date in
            let incompleteTrackers = trackerStore.fetchIncompleteTrackers(by: date)?.isEmpty ?? false
            print("Дата: \(date), Незавершенные трекеры: \(incompleteTrackers ? "Нет" : "Есть")")
            return incompleteTrackers
        }
        
        // 4. Добавляем текущий день в расчет
        if !scheduledDates.contains(today) {
            let incompleteTrackersToday = trackerStore.fetchIncompleteTrackers(by: today)?.isEmpty ?? false
            print("Текущая дата: \(today), Незавершенные трекеры: \(incompleteTrackersToday ? "Нет" : "Есть")")
            
            if incompleteTrackersToday {
                print("Текущий день добавлен как идеальный.")
                perfectDays.append(today)
            }
        }
        
        print("Найдено \(perfectDays.count) идеальных дней.")
        
        // 5. Возвращаем количество "идеальных дней"
        print("=== Конец расчета идеальных дней ===")
        return perfectDays.count
    }

}
